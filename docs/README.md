# Documentation

Study notes, service deep-dives, and operational runbooks for SAA Professional preparation.

## Structure

```
docs/
├── services/          # AWS service deep-dives (one file per service)
│   ├── kms.md
│   ├── iam.md
│   ├── vpc.md
│   └── ...
├── architecture/      # Architecture patterns and design decisions
│   ├── well-architected.md
│   ├── multi-account.md
│   └── ...
└── runbooks/          # Operational procedures for this lab
    ├── eks-lifecycle.md
    ├── disaster-recovery.md
    └── ...
```

## Services Index

| Service | Doc | Lab | Status |
|---------|-----|-----|--------|
| KMS | [kms.md](services/kms.md) | 00 Foundation | Deployed |
| Budgets | [budgets.md](services/budgets.md) | 00 Foundation | Deployed |
| IAM | [iam.md](services/iam.md) | 01 IAM | Planned |
| VPC | [vpc.md](services/vpc.md) | 02 Networking | Planned |
| EKS | [eks.md](services/eks.md) | 03 Compute | Planned |
| S3 | [s3.md](services/s3.md) | 04 Storage | Planned |
| DynamoDB | [dynamodb.md](services/dynamodb.md) | 04 Storage | Planned |
| RDS | [rds.md](services/rds.md) | 04 Storage | Planned |
| CloudWatch | [cloudwatch.md](services/cloudwatch.md) | 05 Observability | Planned |
| Lambda | [lambda.md](services/lambda.md) | 07 Serverless | Planned |
| API Gateway | [api-gateway.md](services/api-gateway.md) | 07 Serverless | Planned |
| SQS / SNS | [sqs-sns.md](services/sqs-sns.md) | 07 Serverless | Planned |
| EventBridge | [eventbridge.md](services/eventbridge.md) | 07 Serverless | Planned |
| Step Functions | [step-functions.md](services/step-functions.md) | 07 Serverless | Planned |
| CloudFront | [cloudfront.md](services/cloudfront.md) | 08 CDN & DNS | Planned |
| Route 53 | [route53.md](services/route53.md) | 08 CDN & DNS | Planned |
| ACM | [acm.md](services/acm.md) | 08 CDN & DNS | Planned |
