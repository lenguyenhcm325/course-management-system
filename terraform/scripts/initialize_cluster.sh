#!/bin/bash
# TODO: considering use chart dependencies instead of helm install each one (if possible)
# TODO: explain the bug with cloudformation

set -e

# update kubeconfig to be able to manage the cluster locally
aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}

# There is some problem with the healthcheck of the pods!!
# https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
# https://skryvets.com/blog/2021/03/15/kubernetes-pull-image-from-private-ecr-registry/

# install ebs csi driver
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
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
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

# TODO: this create-policy might fail if the policy already exists
# create iam policy with the mentioned json policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy${RANDOM_NUMBER} \
    --policy-document file://iam-policy.json

# create serviceaccount with the iam policy
eksctl create iamserviceaccount \
	--cluster=${CLUSTER_NAME} \
	--namespace=kube-system \
	--name=aws-load-balancer-controller${RANDOM_NUMBER} \
	--attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy${RANDOM_NUMBER} \
	--approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update

# download and install aws load balancer controller via helm chart
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller${RANDOM_NUMBER} \
  --set region=${REGION} \
  --set vpcId=${VPC_ID}

# create imagePullSecrets
NAMESPACE_NAME="default" && \
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password) \
  --namespace=$NAMESPACE_NAME || true

# TODO: maybe there is a better way instead of sleep for a certain amount of time?
# wait some time for the aws-load-balancer-controller to start and work properly
sleep 30

cd ../helm/

# deploy the project via helm chart
helm upgrade --install my-cms . --set frontend.image.registry=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com,backend.image.registry=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com,database.auth.rootPassword=nguyen
