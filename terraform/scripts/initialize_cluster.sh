#!/bin/bash
# TODO: consider using chart dependencies instead of helm install each one (if reasonable)

set -eu

# update kubeconfig to be able to manage the cluster remotely
aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}

# install ebs csi driver
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm upgrade --install aws-ebs-csi-driver \
	--namespace kube-system \
	aws-ebs-csi-driver/aws-ebs-csi-driver

# verify that the driver is installed
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver

# associate an iam oidc provider to the cluster
eksctl utils associate-iam-oidc-provider \
	--region ${REGION} \
	--cluster ${CLUSTER_NAME} \
	--approve

# fetch the iam policy json with the required permission for the load balancer controller to work correctly
curl -o iam-policy.json \
  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

# to avoid name clash, a random suffix is added to the policy name
POLICY_NAME=AWSLoadBalancerControllerIAMPolicy${RANDOM_NUMBER}
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

# create iam policy with the mentioned json policy, skip if it already exists
if ! aws iam get-policy --policy-arn "${POLICY_ARN}" &>/dev/null; then
  echo "Policy ${POLICY_NAME} does not exist. Creating now..."

  # Create the policy
  if aws iam create-policy \
      --policy-name "${POLICY_NAME}" \
      --policy-document file://iam-policy.json; then
      echo "Policy ${POLICY_NAME} created successfully."
  else
      echo "Failed to create policy ${POLICY_NAME}."
      exit 1
  fi
else
  echo "Policy ${POLICY_NAME} already exists. Skipping creation."
fi


# due to a CloudFormation bug, the service account's name includes a random suffix
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller${RANDOM_NUMBER}"

# create iam service account and associate it with the iam policy, skip if it already exists
if ! eksctl get iamserviceaccount --cluster=${CLUSTER_NAME} --namespace=${NAMESPACE} | grep -q "${SERVICE_ACCOUNT_NAME}"; then
  echo "IAM Service Account ${SERVICE_ACCOUNT_NAME} does not exist. Creating now..."

  # Create the IAM service account
  if eksctl create iamserviceaccount \
    --cluster=${CLUSTER_NAME} \
    --namespace=kube-system\
    --name=${SERVICE_ACCOUNT_NAME} \
    --attach-policy-arn=${POLICY_ARN} \
    --approve; then
    echo "IAM Service Account ${SERVICE_ACCOUNT_NAME} created successfully."
  else
    echo "Failed to create IAM Service Account ${SERVICE_ACCOUNT_NAME}."
    exit 1
  fi
else
  echo "IAM Service Account ${SERVICE_ACCOUNT_NAME} already exists. Skipping creation."
fi

# add and update the repository containing the load balancer controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# download and install aws load balancer controller via helm chart
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller${RANDOM_NUMBER} \
  --set region=${REGION} \
  --set vpcId=${VPC_ID}

# create imagePullSecrets for ECR authentication
NAMESPACE_NAME="default" && \
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=$NAMESPACE_NAME || true

# wait some time for the aws-load-balancer-controller to start and work properly
echo "Waiting for AWS Load Balancer Controller to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system

# deploy the project via helm chart
cd ../helm/
helm upgrade --install my-cms . \
  --set frontend.image.registry=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com \
  --set backend.image.registry=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com \
  --set database.auth.rootPassword=nguyen

# wait for the application load balancer to be created
echo "Waiting for Load Balancer to be created..."
TIMEOUT=300
start_time=$(date +%s)
while true; do
  LB_HOSTNAME=$(kubectl get ingress alb-ingress -n $NAMESPACE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [ ! -z "$LB_HOSTNAME" ]; then
    echo "Load Balancer created: $LB_HOSTNAME"
    break
  fi
  current_time=$(date +%s)
  elapsed_time=$((current_time - start_time))
  if [ $elapsed_time -ge $TIMEOUT ]; then
    echo "Timeout waiting for Load Balancer"
    exit 1
  fi
  sleep 10
done

DOMAIN="le-nguyen.com"
SUBDOMAIN="cms"
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name $DOMAIN --query "HostedZones[0].Id" --output text)

# prepare the Route 53 change batch
CHANGE_BATCH=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
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

# update the Route 53 record
echo "Updating Route 53 record..."
aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch "$CHANGE_BATCH"

echo "CNAME record updated successfully!"
