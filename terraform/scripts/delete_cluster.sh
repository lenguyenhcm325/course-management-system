#!/bin/bash
set -e

# clean up will be done in a seperate script
# cleanup script to remove these resources? as they are on the aws side not inside the cluster


# Remove the iam policy that is created at the beginning of the cluster
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy"

# Fetch the list of entities attached to the policy
entities=$(aws iam list-entities-for-policy --policy-arn $POLICY_ARN)

# Detach policy from all roles
for role in $(echo "$entities" | jq -r '.PolicyRoles[].RoleName'); do
  echo "Detaching policy from role: $role"
  aws iam detach-role-policy --role-name "$role" --policy-arn "$POLICY_ARN"
done

# Detach policy from all users
for user in $(echo "$entities" | jq -r '.PolicyUsers[].UserName'); do
  echo "Detaching policy from user: $user"
  aws iam detach-user-policy --user-name "$user" --policy-arn "$POLICY_ARN"
done

# Detach policy from all groups
for group in $(echo "$entities" | jq -r '.PolicyGroups[].GroupName'); do
  echo "Detaching policy from group: $group"
  aws iam detach-group-policy --group-name "$group" --policy-arn "$POLICY_ARN"
done

# Delete the policy
echo "Deleting policy: $POLICY_ARN"
aws iam delete-policy --policy-arn "$POLICY_ARN"

# remove the fetched iam-policy.json while initializing cluster
POLICY_FILE="iam-policy.json"
if [ -f "$POLICY_FILE" ]; then
    echo "Deleting policy file: $POLICY_FILE"
    rm "$POLICY_FILE"
else
    echo "Policy file $POLICY_FILE does not exist."
fi

# remove the aws load balancer
# idea: kubectl get ingress, jq
