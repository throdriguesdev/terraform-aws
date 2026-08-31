#!/usr/bin/env bash
# Tear down the cost-bearing lab stacks, keeping the cheap / annoying-to-recreate
# pieces (Route53 zone + KMS) so the next lab-up needs no NS re-delegation.
#
# Destroys:  compute (EKS+nodes+addons+IRSA), data (RDS), networking (VPC+NAT)
# Keeps:     dns (Route53 zone), foundation (KMS + budget)  ~= $1.50/mo idle
#
# Ordering matters: the ALB was created by the LB Controller *inside* the cluster,
# so it must be released (delete the ingress) while LBC is still alive — before any
# tofu destroy — otherwise orphaned ENIs/SGs block the VPC deletion. We poll AWS for
# the ALB to disappear rather than blocking on namespace termination (which can hang
# on finalizers), and sweep any LBC-managed leftovers before destroying networking.
#
# Usage: ./scripts/lab-down.sh -y      (or LAB_YES=1 ./scripts/lab-down.sh)

set -euo pipefail

YES="${LAB_YES:-0}"
[[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]] && YES=1
if [[ "$YES" != "1" ]]; then
  echo "This destroys compute + data + networking (keeps dns + foundation)."
  echo "Re-run with -y to confirm."
  exit 1
fi

# Required identity — sourced from .envrc / direnv, never hardcoded (repo is public).
: "${TF_VAR_aws_profile:?not set — run 'direnv allow' or 'source .envrc' first}"
: "${TF_VAR_account_id:?not set — run 'direnv allow' or 'source .envrc' first}"
export TF_VAR_aws_profile TF_VAR_account_id
export AWS_PROFILE="${AWS_PROFILE:-$TF_VAR_aws_profile}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
LIVE="${REPO_ROOT}/live/dev/us-east-1"
CONTEXT="practice-dev"
REGION="us-east-1"

echo "==> 1/6 Releasing in-cluster AWS resources (delete ingresses so LBC frees the ALB)"
if kubectl --context "$CONTEXT" get ns echo >/dev/null 2>&1; then
  # best-effort, do NOT block on namespace finalizers — the cluster is about to go
  kubectl --context "$CONTEXT" delete ingress --all -n echo --ignore-not-found --wait=false || true
  kubectl --context "$CONTEXT" delete ns echo --ignore-not-found --wait=false || true
else
  echo "    no echo namespace — nothing to release"
fi

echo "==> 2/6 Waiting for k8s-managed ALBs to be deleted (max ~5 min)"
for _ in $(seq 1 30); do
  count="$(aws elbv2 describe-load-balancers --region "$REGION" \
    --query "length(LoadBalancers[?starts_with(LoadBalancerName,'k8s-')])" \
    --output text 2>/dev/null || echo 0)"
  [[ "$count" == "0" ]] && break
  echo "    $count ALB(s) still present, waiting..."
  sleep 10
done

echo "==> 3/6 Destroying compute stack (EKS + node group + addons + IRSA)"
(cd "${LIVE}/compute" && terragrunt stack run destroy --non-interactive)

echo "==> 4/6 Destroying data stack (RDS)"
(cd "${LIVE}/data" && terragrunt stack run destroy --non-interactive)

echo "==> 5/6 Sweeping any LBC-managed leftovers (target groups + security groups)"
for tg in $(aws elbv2 describe-target-groups --region "$REGION" \
    --query "TargetGroups[?starts_with(TargetGroupName,'k8s-')].TargetGroupArn" --output text 2>/dev/null); do
  aws elbv2 delete-target-group --region "$REGION" --target-group-arn "$tg" 2>/dev/null || true
done
for sg in $(aws ec2 describe-security-groups --region "$REGION" \
    --filters "Name=tag:elbv2.k8s.aws/cluster,Values=${CONTEXT}" \
    --query "SecurityGroups[].GroupId" --output text 2>/dev/null); do
  aws ec2 delete-security-group --region "$REGION" --group-id "$sg" 2>/dev/null || true
done

echo "==> 6/6 Destroying networking stack (VPC + NAT gateway)"
(cd "${LIVE}/networking" && terragrunt stack run destroy --non-interactive)

echo ""
echo "==> Done. Kept: dns (Route53 zone), foundation (KMS). Idle cost ~\$1.50/mo."
echo "    Bring it back with: ./scripts/lab-up.sh"
