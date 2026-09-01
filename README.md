# terraform-aws

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-%3E%3D1.6-purple.svg)](https://opentofu.org)
[![Terragrunt](https://img.shields.io/badge/Terragrunt-1.0%20Stacks-orange.svg)](https://terragrunt.gruntwork.io)

Reusable AWS infrastructure modules built with **OpenTofu** and **Terragrunt 1.0 Stacks**. Each module is independently consumable via versioned git reference, and the `live/` directory provides a full working deployment across layered stacks.

---

## Modules

| Module | Path | Description |
|--------|------|-------------|
| `vpc` | `catalog/modules/vpc` | VPC with public / private / database subnets, NAT gateway, route tables |
| `kms` | `catalog/modules/kms` | Customer-managed KMS key with rotation and configurable key policy |
| `budget` | `catalog/modules/budget` | AWS Cost Budget with multi-threshold SNS alerts |
| `route53-zone` | `catalog/modules/route53-zone` | Public (or private) Route 53 hosted zone |
| `rds-postgres` | `catalog/modules/rds-postgres` | RDS PostgreSQL — subnet group, parameter group, security group, managed password |
| `eks` | `catalog/modules/eks` | EKS cluster with OIDC provider, managed node group, EBS CSI, KMS secrets encryption |
| `eks-addons` | `catalog/modules/eks-addons` | AWS Load Balancer Controller, cert-manager, external-dns, external-secrets — all IRSA-wired |
| `argocd` | `catalog/modules/argocd` | ArgoCD via Helm with ALB ingress and cert-manager TLS |

---

## Consuming modules from another repo

Any module can be sourced directly via git tag:

```hcl
terraform {
  source = "git::https://github.com/throdriguesdev/terraform-aws.git//catalog/modules/eks?ref=v1.1.0"
}
```

> [!NOTE]
> Always pin to a release tag (`?ref=vX.Y.Z`) rather than `main` to avoid unintentional changes.

Each module exposes its interface through `variables.tf` and `outputs.tf`. Modules have no side-effect data sources — all inputs (VPC ID, subnet IDs, KMS key ARN, etc.) are passed explicitly by the caller, making them safe to compose in any account or environment.

---

## Deploying the full stack

### Prerequisites

| Tool | Version |
|------|---------|
| [OpenTofu](https://opentofu.org/docs/intro/install/) | >= 1.6 |
| [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) | >= 1.0 |
| AWS CLI | v2 |
| kubectl + helm | any recent |

An AWS account with credentials configured. [direnv](https://direnv.net/) is recommended for profile isolation.

### Setup

```bash
cp .envrc.example .envrc   # set TF_VAR_aws_profile and TF_VAR_account_id
direnv allow               # or: source .envrc
```

### Lifecycle scripts

```bash
./scripts/lab-up.sh       # apply all stacks in order: foundation → networking → dns → compute → data
./scripts/lab-down.sh -y  # destroy cost-bearing stacks, keep dns + foundation
```

> [!TIP]
> `lab-down.sh` drops to idle cost (~$1.50/mo) without losing the Route 53 zone delegation. Useful for spinning the cluster up and down between sessions.

### Stack layout

```
live/dev/us-east-1/
├── foundation/    # KMS key + Budget alerts         (~$1/mo idle)
├── networking/    # VPC, subnets, NAT gateway
├── dns/           # Route 53 public zone            (~$0.50/mo idle)
├── compute/       # EKS cluster + addons + ArgoCD
└── data/          # RDS PostgreSQL
```

Each directory is a **Terragrunt 1.0 Stack** — a single file (`terragrunt.stack.hcl`) declares all units and their dependency order.

```bash
# Run from any stack directory
terragrunt stack run plan
terragrunt stack run apply
terragrunt stack run destroy
```

---

## What's included

| Area | Components | Status |
|------|------------|--------|
| Foundation | KMS CMK, AWS Budget + SNS | ✅ |
| Networking | VPC, 3-tier subnets, NAT gateway | ✅ |
| DNS / TLS | Route 53 zone, cert-manager (DNS01 solver), external-dns | ✅ |
| Compute | EKS 1.32, managed Spot node group, EBS CSI driver, OIDC / IRSA | ✅ |
| Ingress | AWS Load Balancer Controller (ALB) | ✅ |
| Secrets | external-secrets (SSM Parameter Store + Secrets Manager) | ✅ |
| GitOps | ArgoCD (Helm, ALB ingress, cert-manager TLS) | ✅ |
| Data | RDS PostgreSQL (gp3, managed password, Performance Insights) | ✅ |

---

## Cost

> [!WARNING]
> The full stack is **not free**. Tear down with `lab-down.sh` after each session to avoid unexpected charges.

| State | Approximate cost |
|-------|-----------------|
| Idle (dns + foundation only) | ~$1.50 / mo |
| Full stack (EKS + NAT + Spot nodes + ALB) | ~$0.20 / hr |

The biggest cost drivers are the EKS control plane ($0.10/hr), NAT Gateway ($0.045/hr + data transfer), and ALB ($0.025/hr base). Spot nodes (t3.small) are ~$0.008/hr each.

---

## License

[Apache 2.0](LICENSE) © Thiago Rodrigues
