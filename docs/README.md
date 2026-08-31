# Documentation

Build notes, AWS service deep-dives, and operational runbooks for the lab. These grow as new pieces get built — they're working references, not a certification checklist (though they're handy for SAA-Pro study too).

## Structure

```
docs/
├── services/          # AWS service deep-dives (one file per service)
│   ├── kms.md
│   ├── budgets.md
│   ├── vpc.md
│   └── ...
├── architecture/      # Architecture patterns and design decisions
│   ├── well-architected.md
│   ├── gitops.md
│   └── ...
└── runbooks/          # Operational procedures for this lab
    ├── eks-lifecycle.md
    ├── disaster-recovery.md
    └── ...
```

## Services Index

| Service | Doc | Area | Status |
|---------|-----|------|--------|
| KMS | [kms.md](services/kms.md) | Foundation | Done |
| Budgets | [budgets.md](services/budgets.md) | Foundation | Done |
| VPC | [vpc.md](services/vpc.md) | Networking | Done |
| EKS | [eks.md](services/eks.md) | Compute | Done |
| Route 53 | [route53.md](services/route53.md) | DNS / TLS | Done |
| ACM / cert-manager | [tls.md](services/tls.md) | DNS / TLS | Done |
| RDS | [rds.md](services/rds.md) | Data | Done |
| ArgoCD | [argocd.md](services/argocd.md) | GitOps | In progress |
| IAM | [iam.md](services/iam.md) | Security | Planned |
| S3 | [s3.md](services/s3.md) | Storage | Planned |
| DynamoDB | [dynamodb.md](services/dynamodb.md) | Storage | Planned |
| CloudWatch | [cloudwatch.md](services/cloudwatch.md) | Observability | Planned |
| Lambda | [lambda.md](services/lambda.md) | Serverless | Planned |
| API Gateway | [api-gateway.md](services/api-gateway.md) | Serverless | Planned |
| SQS / SNS | [sqs-sns.md](services/sqs-sns.md) | Serverless | Planned |
| CloudFront | [cloudfront.md](services/cloudfront.md) | CDN | Planned |
