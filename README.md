# Terraform AWS Practice Lab

AWS infrastructure practice environment using **Terragrunt 1.0 Stacks** pattern with reusable catalog units.

Built for SAA Professional certification prep — covers Organizations/IAM, networking, EKS, serverless, DR/multi-region, and more.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2
- An AWS account with credentials configured (`aws configure`)

## Setup

```bash
# 1. Clone the repo
git clone <repo-url> && cd terraform-aws

# 2. Configure your environment
cp .envrc.example .envrc
# Edit .envrc with your AWS profile, account ID, and email

# 3. Load environment variables
source .envrc
# Or if using direnv: direnv allow

# 4. Deploy foundation (creates state backend automatically)
cd live/dev/us-east-1/foundation
terragrunt stack run apply --all
```

## Structure

```
.
├── root.hcl                    # Terragrunt root config (state, provider, catalog)
├── account.hcl                 # AWS account ID (from env var)
├── .envrc.example              # Template for local environment variables
│
├── catalog/                    # Reusable infrastructure catalog
│   ├── modules/                # Custom Terraform modules
│   │   ├── kms/                # KMS key with rotation + key policy
│   │   └── budget/             # AWS Budget + SNS notifications
│   └── units/                  # Terragrunt unit templates
│       ├── kms/                # Unit wrapping modules/kms
│       ├── budget/             # Unit wrapping modules/budget
│       └── vpc/                # Unit wrapping terraform-aws-modules/vpc/aws
│
├── live/                       # Environment deployments
│   ├── dev/us-east-1/          # Primary practice environment
│   │   ├── foundation/         # KMS + Budget alarm (always-on, ~$1/mo)
│   │   └── networking/         # VPC with toggleable NAT (~$0 without NAT)
│   ├── staging/                # Skeleton (proves multi-env pattern)
│   └── prod/                   # Skeleton (proves multi-env pattern)
│
└── scripts/
    └── cost-check.sh           # Query AWS Cost Explorer vs $100 budget
```

## How It Works

This repo uses **Terragrunt 1.0 Explicit Stacks**:

1. **Catalog** (`catalog/`) — reusable modules and unit templates
2. **Live** (`live/`) — stack files that compose units with environment-specific values
3. **Stacks** (`terragrunt.stack.hcl`) — declare which units to deploy and pass values to them

```bash
# Generate units from a stack definition
terragrunt stack generate

# Plan all units in a stack
terragrunt stack run plan --all

# Apply all units
terragrunt stack run apply --all

# Destroy all units
terragrunt stack run destroy --all

# Clean generated files
terragrunt stack clean
```

## Labs

| # | Lab | Cost | Status |
|---|-----|------|--------|
| 00 | Foundation (KMS, Budget) | ~$1/mo | Ready |
| 01 | IAM & Security | $0 | Planned |
| 02 | Networking (VPC, peering) | $0 base | Ready |
| 03 | EKS | ~$3.40/day | Planned |
| 04 | Storage (S3, DynamoDB, RDS) | ~$0 | Planned |
| 05 | Observability | ~$0 | Planned |
| 06 | GitOps (ArgoCD) | on EKS | Planned |
| 07 | Serverless (Lambda, APIGW, SQS) | ~$0 | Planned |
| 08 | CDN & DNS (CloudFront, Route53) | ~$0.50/mo | Planned |
| 09 | DR & Multi-Region | ~$1/day | Planned |

## Cost Management

Budget: **$100 AWS credits**

- Always-on baseline (foundation + networking without NAT): ~$1/month
- EKS session (6 hours): ~$1.50
- Use `scripts/cost-check.sh` to monitor spend
- NAT Gateway disabled by default (`enable_nat = false`) — toggle on only for EKS
