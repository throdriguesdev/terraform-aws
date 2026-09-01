# Amazon VPC (Virtual Private Cloud)

## What It Is

Logically isolated virtual network within AWS. You control IP addressing, subnets, route tables, gateways, and network ACLs. Every AWS resource that needs networking (EC2, EKS, RDS, Lambda in VPC mode) lives in a VPC.

## What We Deployed

```
VPC:    main-dev (10.0.0.0/16)
Region: us-east-1
AZs:    us-east-1a, us-east-1b, us-east-1c
Tiers:  3 (public, private, isolated/database)
NAT:    disabled (toggle on for EKS)
```

### Architecture

```
┌──────────────────────────────────────────────────────────────┐
│ VPC: main-dev (10.0.0.0/16)                                 │
│                                                              │
│  Public Subnets → Route: 0.0.0.0/0 → IGW                    │
│  ┌──────────────┬──────────────┬──────────────┐              │
│  │ 10.0.0.0/20  │ 10.0.16.0/20│ 10.0.32.0/20 │              │
│  │ (AZ-a)       │ (AZ-b)      │ (AZ-c)       │              │
│  └──────────────┴──────────────┴──────────────┘              │
│                                                              │
│  Private Subnets → Route: 0.0.0.0/0 → NAT (when enabled)    │
│  ┌──────────────┬──────────────┬──────────────┐              │
│  │ 10.0.48.0/20 │ 10.0.64.0/20│ 10.0.80.0/20 │              │
│  │ (AZ-a)       │ (AZ-b)      │ (AZ-c)       │              │
│  └──────────────┴──────────────┴──────────────┘              │
│                                                              │
│  Database Subnets → Route: local only (NO internet)          │
│  ┌──────────────┬──────────────┬──────────────┐              │
│  │ 10.0.96.0/20 │10.0.112.0/20│10.0.128.0/20 │              │
│  │ (AZ-a)       │ (AZ-b)      │ (AZ-c)       │              │
│  └──────────────┴──────────────┴──────────────┘              │
│                                                              │
│  Reserved: 10.0.144.0/20 — 10.0.240.0/20 (~28K IPs)         │
└──────────────────────────────────────────────────────────────┘
```

### CIDR Allocation

| Tier | AZ-a | AZ-b | AZ-c | IPs/subnet |
|------|------|------|------|------------|
| Public | 10.0.0.0/20 | 10.0.16.0/20 | 10.0.32.0/20 | 4,094 |
| Private | 10.0.48.0/20 | 10.0.64.0/20 | 10.0.80.0/20 | 4,094 |
| Database | 10.0.96.0/20 | 10.0.112.0/20 | 10.0.128.0/20 | 4,094 |

Why /20? EKS VPC-CNI assigns **one IP per pod**. With /24 (254 IPs), you'd run out quickly. /20 gives 4,094 IPs per subnet — enough for hundreds of pods per AZ.

## Core Components

### VPC
- CIDR block defines the IP range (we use /16 = 65,536 IPs)
- `enable_dns_support` + `enable_dns_hostnames` = required for many AWS services (EKS, ELB, RDS endpoints)
- One VPC per environment is the standard pattern (dev/staging/prod each get their own)

### Subnets
A subnet is a range of IPs within a VPC, tied to **one AZ**. AWS reserves 5 IPs per subnet (first 4 + last 1).

| Type | Internet Access | Use For |
|------|----------------|---------|
| **Public** | Direct via IGW | ALBs, NAT Gateways, bastion hosts |
| **Private** | Outbound via NAT (if enabled) | EKS nodes, Lambda, application servers |
| **Isolated** | None | RDS, ElastiCache, data stores |

### Internet Gateway (IGW)
- Allows public subnets to reach the internet
- One per VPC, horizontally scaled by AWS, no bandwidth limit
- Free (no hourly cost, no data processing cost beyond standard transfer)
- Public subnet route table must have `0.0.0.0/0 → IGW`

### NAT Gateway
- Allows private subnets to initiate outbound connections (e.g., pull container images)
- **$0.045/hr** ($32.40/mo) + $0.045/GB processed — the silent budget killer
- Placed in a public subnet, private route table points `0.0.0.0/0 → NAT GW`
- Options:
  - **Single NAT** (what we use): one NAT in AZ-a, all private subnets route through it. Saves money, but AZ-a failure = no outbound for private subnets
  - **NAT per AZ**: one NAT per AZ for HA. 3x the cost.
- We keep NAT **disabled by default** and toggle it on only for EKS sessions

### Route Tables
Each subnet is associated with exactly one route table. A route table has rules (routes) that determine where traffic goes.

```
Public RT:    10.0.0.0/16 → local,  0.0.0.0/0 → IGW
Private RT:   10.0.0.0/16 → local,  0.0.0.0/0 → NAT (when enabled)
Database RT:  10.0.0.0/16 → local   (no 0.0.0.0/0 route at all)
```

The `local` route (VPC CIDR) is automatic and cannot be removed — all subnets can talk to each other within the VPC by default. Use **security groups** and **NACLs** to restrict this.

## Network ACLs vs Security Groups

| Feature | Security Groups | NACLs |
|---------|----------------|-------|
| Level | Instance/ENI | Subnet |
| State | **Stateful** (return traffic auto-allowed) | **Stateless** (must allow both directions) |
| Rules | Allow only | Allow AND Deny |
| Evaluation | All rules evaluated | Rules evaluated in order (lowest number wins) |
| Default | Deny all inbound, allow all outbound | Allow all |
| Use case | Primary firewall for resources | Subnet-level guardrails, deny-list patterns |

**Best practice:** Use security groups as primary firewall. Use NACLs only for subnet-level deny rules (e.g., block a known bad IP range).

## VPC Peering vs Transit Gateway

| Feature | VPC Peering | Transit Gateway |
|---------|------------|-----------------|
| Topology | Point-to-point (1:1) | Hub-and-spoke (many:1) |
| Transitive routing | **No** | **Yes** |
| Cross-region | Yes | Yes |
| Cross-account | Yes | Yes |
| Bandwidth | No limit | Up to 50 Gbps per attachment |
| Cost | Free (data transfer only) | $0.05/hr + $0.02/GB |
| Scale | Up to 125 peering connections | Up to 5,000 attachments |

**Decision guide:** <10 VPCs → peering is simpler and free. >10 VPCs or need transitive routing → Transit Gateway.

## VPC Endpoints

Allow private connectivity to AWS services without going through the internet/NAT.

| Type | How It Works | Services | Cost |
|------|-------------|----------|------|
| **Gateway** | Route table entry, no ENI | S3, DynamoDB | **Free** |
| **Interface** (PrivateLink) | ENI in your subnet | Most other services (ECR, STS, KMS, etc.) | $0.01/hr + $0.01/GB |

**Cost tip:** Gateway endpoints for S3 and DynamoDB are free and reduce NAT costs (traffic to S3/DynamoDB doesn't go through NAT). Always create them.

## VPC Flow Logs

Captures metadata about IP traffic going to/from network interfaces in the VPC.

| Destination | Cost | Query |
|------------|------|-------|
| CloudWatch Logs | $0.50/GB ingestion | CloudWatch Insights |
| S3 | $0.023/GB storage | Athena ($5/TB scanned) |
| Kinesis Data Firehose | $0.029/GB | Real-time processing |

We skipped flow logs for now — can add later when practicing security analysis.

## EKS-Specific Subnet Tags

For EKS to auto-discover subnets for load balancers:

```
Public subnets:  kubernetes.io/role/elb = 1          (internet-facing ALBs)
Private subnets: kubernetes.io/role/internal-elb = 1  (internal ALBs)
Both:            kubernetes.io/cluster/<name> = shared (if multiple clusters share the VPC)
```

We pre-tagged public and private subnets for future EKS deployment.

## Cost

| Component | Cost |
|-----------|------|
| VPC, subnets, route tables, IGW | **Free** |
| NAT Gateway | $0.045/hr + $0.045/GB |
| VPC Endpoints (Interface) | $0.01/hr per AZ |
| VPC Endpoints (Gateway) | Free |
| VPC Peering | Free (data transfer charges apply) |
| Transit Gateway | $0.05/hr per attachment |
| VPC Flow Logs | Destination storage costs |

Our current cost: **$0/month** (no NAT, no VPC endpoints, no flow logs).

## Key Concepts

- 3-tier subnet pattern: public (ALBs, NAT), private (workloads), isolated (databases with no outbound)
- NAT Gateway is single-AZ — for HA, deploy one per AZ (3x cost)
- VPC peering is NOT transitive: A↔B and B↔C does NOT mean A↔C — Transit Gateway handles that
- Gateway endpoints (S3, DynamoDB) are free and route-table-based; Interface endpoints use ENIs and cost $0.01/hr per AZ
- VPC CIDRs cannot overlap with peered VPCs — plan CIDR allocation before peering
- Secondary CIDRs can be added to a VPC (up to 5 total) — useful when running out of IPs
- `enableDnsHostnames` must be true for RDS, ELB, and VPC endpoints to resolve DNS names
- Private subnets can reach AWS services via VPC endpoints instead of NAT — significantly cheaper at scale
- CIDR /28 is the minimum subnet size, /16 is the maximum VPC size
- IPv6: VPC supports dual-stack; Egress-only IGW is the IPv6 equivalent of NAT (outbound only)
