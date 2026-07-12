# AWS Practice Lab

A hands-on playground for building **real projects on AWS** — using the **Terragrunt 1.0 Stacks** pattern on **OpenTofu**, plus the cloud-native toolchain around them (EKS, ArgoCD, external-dns, cert-manager, external-secrets, RDS, Route53).

The point is to practice by *building and operating* actual infrastructure: spin a piece up, get it working end-to-end, tear it down to save credits, repeat. Certification prep (including AWS SAA-Professional) is one use of the lab — not the reason it exists.

## Prerequisites

- [OpenTofu](https://opentofu.org/docs/intro/install/) >= 1.6
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2, plus `kubectl` and `helm` for the EKS stacks
- An AWS account with credentials configured, and (optionally) [direnv](https://direnv.net/)

## Quick start

```bash
# 1. Configure your environment (values stay local — .envrc is gitignored)
cp .envrc.example .envrc      # set AWS profile, account ID, notification email
direnv allow                  # or: source .envrc

# 2. Bring the whole lab up (foundation → networking → dns → compute → data + kubeconfig)
./scripts/lab-up.sh

# 3. Tear the cost-bearing pieces down when you're done
./scripts/lab-down.sh -y      # keeps dns + foundation (~$1.50/mo idle)
```

## Structure

```
.
├── root.hcl                    # Terragrunt root (state backend, provider, catalog)
├── account.hcl                 # AWS account ID (sourced from env var — not committed)
├── .envrc.example              # Template for local environment variables
│
├── catalog/                    # Reusable infrastructure catalog
│   ├── modules/                # Custom OpenTofu modules:
│   │   │                       #   kms, budget, vpc, eks, eks-addons,
│   │   └── ...                 #   rds-postgres, route53-zone
│   └── units/                  # Terragrunt unit templates (one wrapper per module)
│
├── live/dev/us-east-1/         # Environment deployments (stacks)
│   ├── foundation/             # KMS + Budget          — kept when idle (~$1/mo)
│   ├── networking/             # VPC + NAT gateway
│   ├── dns/                    # Route53 zone          — kept when idle (~$0.50/mo)
│   ├── compute/                # EKS + Spot nodes + system addons (IRSA)
│   └── data/                   # RDS Postgres
│
├── apps/                       # Kubernetes workloads + platform config
│   ├── system/                 # addon config: LBC, cert-manager, external-dns, external-secrets
│   └── services/               # demo workloads (echo)
├── gitops/                     # ArgoCD app-of-apps (in progress)
├── docs/                       # service deep-dives + runbooks
└── scripts/
    ├── lab-up.sh               # apply all stacks + update kubeconfig
    ├── lab-down.sh             # release ALBs, destroy cost-bearing stacks, keep dns+foundation
    ├── eks-connect.sh          # add the cluster kube-context
    └── cost-check.sh           # Cost Explorer vs budget
```

## How it works

This repo uses **Terragrunt 1.0 Explicit Stacks**:

1. **Catalog** (`catalog/`) — reusable modules + unit templates
2. **Live** (`live/`) — `terragrunt.stack.hcl` files compose units with environment-specific values
3. **Stacks** generate the units, resolve cross-stack dependencies, and apply together

```bash
terragrunt stack run plan       # plan every unit in the current stack
terragrunt stack run apply      # apply
terragrunt stack run destroy    # destroy
terragrunt stack clean          # remove generated units
```

Most of the time you'll just use `scripts/lab-up.sh` / `lab-down.sh`, which run these in the right order and handle the parts Terraform can't (releasing the LB-Controller-created ALB before destroy).

## What's built

| Area | Components | Status |
|------|-----------|--------|
| Foundation | KMS (rotation + policy), Budget + SNS | Done |
| Networking | VPC, subnets, NAT gateway | Done |
| DNS / TLS | Route53 zone, cert-manager (Route53 DNS01), external-dns | Done |
| Compute | EKS, managed Spot nodes, EBS CSI, OIDC/IRSA | Done |
| Ingress | AWS Load Balancer Controller (ALB) | Done |
| Secrets | external-secrets (SSM / Secrets Manager) | Done |
| Data | RDS Postgres | Done |
| GitOps | ArgoCD app-of-apps | In progress |
| Serverless | Lambda, API Gateway, SQS/SNS, EventBridge | Planned |
| Observability | CloudWatch, metrics/logs pipelines | Planned |
| DR / Multi-region | cross-region replication, failover | Planned |

## Cost & lifecycle

Budget: **$100 AWS credits** — so the lab is designed to be ephemeral.

- **Idle** (only `dns` + `foundation` kept): **~$1.50/mo**
- **Full lab up** (EKS control plane, NAT gateway, Spot nodes, RDS, ALB): **~$0.20/hr** — tear it down when you're not using it
- `./scripts/lab-down.sh` drops to idle; `./scripts/lab-up.sh` resumes **without re-delegating DNS** (the Route53 zone is kept, so no waiting on NS propagation in your registrar)
- `./scripts/cost-check.sh` monitors spend against the budget
