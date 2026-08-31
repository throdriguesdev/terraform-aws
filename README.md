# terraform-aws

A reusable catalog of **AWS infrastructure modules** built with Terragrunt 1.0 Stacks on OpenTofu.

Designed to be consumed by external deployment repos (like [devopsdays-fsa](https://github.com/throdriguesdev/devopsdays-fsa)) via versioned git references, and also usable standalone as a practice lab.

## What's in the catalog

| Module | Description |
|--------|-------------|
| `vpc` | VPC, public/private subnets, NAT gateway |
| `kms` | KMS key with rotation + cluster encryption policy |
| `budget` | AWS Budget with SNS alert |
| `route53-zone` | Public hosted zone |
| `rds-postgres` | RDS PostgreSQL with subnet group |
| `eks` | EKS cluster, OIDC/IRSA, managed Spot node group, EBS CSI |
| `eks-addons` | LBC, cert-manager (Route53 DNS01), external-dns, external-secrets — all IRSA-wired |
| `argocd` | ArgoCD via Helm, ALB ingress + TLS via cert-manager |
| `ec2-game-server` | Opinionated EC2 game server (Project Zomboid / similar) |

## Consuming modules from another repo

Reference any module by git URL + tag:

```hcl
terraform {
  source = "git::https://github.com/throdriguesdev/terraform-aws.git//catalog/modules/eks?ref=v1.0.0"
}
```

See [devopsdays-fsa](https://github.com/throdriguesdev/devopsdays-fsa) for a full working example that deploys an observability-ready EKS cluster using this catalog.

## Using as a standalone lab

### Prerequisites

- [OpenTofu](https://opentofu.org/docs/intro/install/) >= 1.6
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 1.0
- AWS CLI v2 + `kubectl` + `helm`
- An AWS account with credentials configured; optionally [direnv](https://direnv.net/)

### Quick start

```bash
cp .envrc.example .envrc      # set TF_VAR_aws_profile, TF_VAR_account_id
direnv allow                  # or: source .envrc

./scripts/lab-up.sh           # foundation → networking → dns → compute
./scripts/lab-down.sh -y      # tear down cost-bearing pieces (keeps dns + foundation)
```

### Stack structure

```
live/dev/us-east-1/
  foundation/     # KMS + Budget          (~$1/mo idle)
  networking/     # VPC + NAT gateway
  dns/            # Route53 zone          (~$0.50/mo idle)
  compute/        # EKS + Spot nodes + addons + ArgoCD
  data/           # RDS Postgres
```

```bash
# within any stack directory:
terragrunt stack run plan
terragrunt stack run apply
terragrunt stack run destroy
```

## What's built

| Area | Components | Status |
|------|-----------|--------|
| Foundation | KMS, Budget + SNS | Done |
| Networking | VPC, subnets, NAT gateway | Done |
| DNS / TLS | Route53 zone, cert-manager (DNS01), external-dns | Done |
| Compute | EKS 1.32, managed Spot nodes, EBS CSI, OIDC/IRSA | Done |
| Ingress | AWS Load Balancer Controller (ALB) | Done |
| Secrets | external-secrets (SSM / Secrets Manager) | Done |
| GitOps | ArgoCD (Helm, ALB ingress, TLS) | Done |
| Data | RDS Postgres | Done |
| Observability | Grafana + LGTM stack (via devopsdays-fsa GitOps) | External |

## Cost

- **Idle** (dns + foundation only): **~$1.50/mo**
- **Full lab** (EKS control plane + NAT + Spot nodes + ALB): **~$0.20/hr**

`./scripts/lab-down.sh` drops to idle cost without losing the Route53 zone delegation.
