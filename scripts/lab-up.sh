#!/usr/bin/env bash
# Bring the lab back up. Applies stacks in dependency order — the kept stacks
# (foundation, dns) are idempotent no-ops if they already exist, so this works
# whether resuming after lab-down.sh or building from a clean account.
#
# Usage: ./scripts/lab-up.sh

set -euo pipefail

# Required identity — sourced from .envrc / direnv, never hardcoded (repo is public).
: "${TF_VAR_aws_profile:?not set — run 'direnv allow' or 'source .envrc' first}"
: "${TF_VAR_account_id:?not set — run 'direnv allow' or 'source .envrc' first}"
export TF_VAR_aws_profile TF_VAR_account_id
export AWS_PROFILE="${AWS_PROFILE:-$TF_VAR_aws_profile}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
LIVE="${REPO_ROOT}/live/dev/us-east-1"
CONTEXT="practice-dev"
REGION="us-east-1"

echo "==> 1/5 foundation (KMS + budget)"
(cd "${LIVE}/foundation" && terragrunt stack run apply --non-interactive)

echo "==> 2/5 networking (VPC + NAT)"
(cd "${LIVE}/networking" && terragrunt stack run apply --non-interactive)

echo "==> 3/5 dns (Route53 zone)"
(cd "${LIVE}/dns" && terragrunt stack run apply --non-interactive)

echo "==> 4/5 compute (EKS + node group + addons)"
(cd "${LIVE}/compute" && terragrunt stack run apply --non-interactive)

echo "==> 5/5 data (RDS)"
(cd "${LIVE}/data" && terragrunt stack run apply --non-interactive)

echo "==> Updating kubeconfig"
aws eks update-kubeconfig --name "$CONTEXT" --region "$REGION" \
  --profile "$TF_VAR_aws_profile" --alias "$CONTEXT"

echo ""
echo "==> Lab up. Check nodes with:"
echo "    kubectl --context ${CONTEXT} get nodes"
