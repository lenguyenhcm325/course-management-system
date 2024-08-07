#!/bin/bash

set -e

# update kubeconfig to be able to manage the cluster remotely
aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}

# delete the CNAME entry that previously points to the load balancer hostname
DOMAIN="le-nguyen.com"
SUBDOMAIN="cms"
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name $DOMAIN --query "HostedZones[0].Id" --output text)

LB_HOSTNAME=$(kubectl get ingress alb-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Deleting Route 53 CNAME record..."
CHANGE_BATCH=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "DELETE",
      "ResourceRecordSet": {
        "Name": "${SUBDOMAIN}.${DOMAIN}",
        "Type": "CNAME",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "${LB_HOSTNAME}"
          }
        ]
      }
    }
  ]
}
EOF
)

aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch "$CHANGE_BATCH" || true

echo "CNAME record deleted successfully!"

# remove the IAM policy
echo "Removing IAM policy..."
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy${RANDOM_NUMBER}"

# list all roles attached to the policy
ATTACHED_ROLES=$(aws iam list-entities-for-policy --policy-arn $POLICY_ARN --entity-filter Role --query 'PolicyRoles[*].RoleName' --output text || true)

# detach the policy from all attached roles
for ROLE in $ATTACHED_ROLES
do
  echo "Detaching policy from role: $ROLE"
  aws iam detach-role-policy --role-name $ROLE --policy-arn $POLICY_ARN
done

# delete the policy
aws iam delete-policy --policy-arn $POLICY_ARN || true

echo "IAM policy removed successfully!"

# remove the OIDC provider associated with the cluster
echo "Removing OIDC provider..."
OIDC_PROVIDER=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///" || true)
if [[ -n "$OIDC_PROVIDER" ]]; then
  aws iam delete-open-id-connect-provider --open-id-connect-provider-arn arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}
else
  echo "OIDC_PROVIDER is empty. Skipping deletion."
fi

echo "Deleting and waiting for Load Balancer to be fully deleted..."

# function to get load balancer ARN
get_lb_arn() {
    aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='${VPC_ID}'].LoadBalancerArn" --output text
}

# initial check for load balancer
LB_ARN=$(get_lb_arn)

if [ -z "$LB_ARN" ]; then
  echo "No Load Balancer found in the specified VPC."
  exit 0
fi

# delete the load balancer
echo "Deleting Load Balancer: $LB_ARN"
aws elbv2 delete-load-balancer --load-balancer-arn $LB_ARN

# set timeout (in seconds)
TIMEOUT=600
START_TIME=$(date +%s)

# wait for the load balancer to be fully deleted
while true; do
  CURRENT_TIME=$(date +%s)
  ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

  if [ $ELAPSED_TIME -ge $TIMEOUT ]; then
      echo "Timeout reached. Load Balancer deletion process took too long."
      exit 1
  fi

  echo "Time elapsed while waiting for Load Balancer to be deleted: ${ELAPSED_TIME}s"

  LB_ARN=$(get_lb_arn)

  if [ -z "$LB_ARN" ]; then
      echo "The Load Balancer associated with the cluster's VPC has been deleted."
      break
  fi

  HOSTNAME=$(aws elbv2 describe-load-balancers --load-balancer-arns $LB_ARN --query "LoadBalancers[0].DNSName" --output text)
  echo "Waiting for Load Balancer to be deleted... Current hostname: $HOSTNAME"

  sleep 30
done

echo "Load Balancer deletion process completed."

# remove the IAM service account
echo "Removing IAM service account..."
eksctl delete iamserviceaccount \
  --cluster=${CLUSTER_NAME} \
  --namespace=kube-system \
  --name=aws-load-balancer-controller${RANDOM_NUMBER} || true

echo "Cleanup completed successfully!"
