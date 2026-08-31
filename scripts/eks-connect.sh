#!/usr/bin/env bash
# Updates ~/dotfiles/kube-config with the practice-dev cluster context.
# Usage: ./scripts/eks-connect.sh [environment] [region]

set -euo pipefail

ENV="${1:-dev}"
REGION="${2:-us-east-1}"
PROFILE="${TF_VAR_aws_profile:-th}"
KUBECONFIG_FILE="${HOME}/dotfiles/kube-config"
STACK_UNIT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}/live/${ENV}/${REGION}/compute/.terragrunt-stack/eks"

echo "Reading cluster name from state..."
CLUSTER_NAME=$(cd "$STACK_UNIT" && tofu output -raw cluster_name 2>/dev/null || echo "practice-${ENV}")

echo "Updating ${KUBECONFIG_FILE} with context for ${CLUSTER_NAME}..."
aws eks update-kubeconfig \
  --kubeconfig "$KUBECONFIG_FILE" \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --profile "$PROFILE" \
  --alias "$CLUSTER_NAME"

echo ""
echo "Context '${CLUSTER_NAME}' added. Switch to it with:"
echo "  kubectl config use-context ${CLUSTER_NAME}"
echo ""
echo "Don't forget to commit the updated kube-config:"
echo "  cd ~/dotfiles && git add kube-config && git commit -m 'add practice-dev eks context'"
