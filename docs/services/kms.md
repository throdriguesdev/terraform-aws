# AWS KMS (Key Management Service)

## What It Is

Managed service for creating and controlling encryption keys used to encrypt data across AWS services and applications. KMS integrates with most AWS services that support encryption (S3, EBS, RDS, EKS, CloudWatch Logs, etc.).

## What We Deployed

```
KMS Key: <KEY_ID>
Alias:   alias/practice-dev
Region:  us-east-1
```

**Configuration:**
- Symmetric key (AES-256-GCM) — the default and most common type
- Automatic key rotation enabled (rotates every 365 days)
- Key policy grants full access to the root account
- Deletion window: 7 days (minimum) — safety net against accidental deletion

**Why we created it:**
- Single CMK for encrypting resources across all labs (S3, EBS volumes, EKS secrets, RDS, CloudWatch Logs)
- Centralizes key management — one key policy to audit
- Enables encryption at rest for everything — single key to audit across all services

## Key Types

| Type | Algorithm | Use Case | Example |
|------|-----------|----------|---------|
| **Symmetric** (default) | AES-256-GCM | Encrypt/decrypt data, generate data keys | S3 SSE-KMS, EBS, RDS encryption |
| **Asymmetric RSA** | RSA 2048/3072/4096 | Encrypt/decrypt or sign/verify outside AWS | External apps that can't call KMS API |
| **Asymmetric ECC** | ECC NIST P-256/384/521 | Digital signatures | JWT signing, document signing |
| **HMAC** | HMAC-SHA-256/384/512 | Generate and verify MACs | API request authentication |

**When to pick asymmetric:** only when an external party needs the public key and can't call KMS directly (e.g., verifying signatures outside AWS).

## Key Categories

| Category | Who Manages | Cost | You Control Policy? |
|----------|------------|------|---------------------|
| **AWS Owned** | AWS | Free | No — fully managed by AWS |
| **AWS Managed** (`aws/s3`, `aws/ebs`, etc.) | AWS | Free (no monthly fee, but per-request) | No — default policy, can't modify |
| **Customer Managed (CMK)** | You | $1/mo + API calls | Yes — full control over key policy |
| **External (imported)** | You (key material from outside) | $1/mo + API calls | Yes — you bring your own key material |
| **Custom Key Store** | You (CloudHSM backed) | $1/mo + CloudHSM costs | Yes — backed by your HSM cluster |

**What we use:** Customer Managed Key (CMK) — `alias/practice-dev`. This gives us full control over the key policy, which is needed for cross-service encryption and IAM-based access control.

## How Encryption Works

### Envelope Encryption (how KMS actually encrypts data)

KMS does NOT encrypt your data directly (4KB limit on direct encrypt). Instead:

```
1. You call GenerateDataKey → KMS returns:
   - Plaintext data key (use it to encrypt your data)
   - Encrypted data key (encrypted with your CMK)

2. Encrypt your data with the plaintext data key (client-side)
3. Store the encrypted data + encrypted data key together
4. Delete the plaintext data key from memory

To decrypt:
1. Send the encrypted data key to KMS → KMS decrypts it using the CMK
2. Use the plaintext data key to decrypt your data
```

AWS services do this automatically (S3, EBS, RDS all use envelope encryption under the hood).

### SSE Types for S3

| Type | Key Managed By | Header |
|------|---------------|--------|
| SSE-S3 | AWS (default since Jan 2023) | `x-amz-server-side-encryption: AES256` |
| SSE-KMS | KMS (your CMK or AWS managed) | `x-amz-server-side-encryption: aws:kms` |
| SSE-C | Customer (you provide key each request) | `x-amz-server-side-encryption-customer-*` |
| DSSE-KMS | KMS (dual-layer) | `x-amz-server-side-encryption: aws:kms:dsse` |

## Key Policy vs IAM Policy

Both control access to KMS keys, but they work differently:

**Key Policy** (resource-based, attached to the key):
- Every KMS key MUST have a key policy
- The key policy is the primary access control mechanism
- If the key policy doesn't allow it, IAM policies alone can't grant access
- Our key policy grants `kms:*` to the root account, which then delegates to IAM

**IAM Policy** (identity-based, attached to users/roles):
- Only works if the key policy allows IAM policies to grant access (our `EnableRootAccountAccess` statement does this)
- Used for granting specific users/roles access to specific key operations

**Grants** (temporary, programmatic access):
- Used by AWS services to use your CMK on your behalf
- Example: EBS creates a grant to encrypt/decrypt volumes with your key
- Can be revoked without changing the key policy

## Key Rotation

| Rotation Type | Who Rotates | Period | What Changes |
|--------------|------------|--------|--------------|
| **Automatic** (enabled) | AWS | 365 days (configurable 90-2560) | New key material, same key ID and alias |
| **Manual** | You | Whenever | Create new key, update alias to point to it, old key kept for decryption |

We enabled automatic rotation. The key ID stays the same — KMS internally tracks which key material version encrypted each piece of data.

## Multi-Region Keys

KMS supports multi-region keys for disaster recovery:
- One **primary key** in your main region
- **Replica keys** in other regions (same key material, different ARN)
- Encrypt in us-east-1, decrypt in us-west-2 without cross-region API calls
- Relevant for Lab 09 (DR & Multi-Region)

## Cost

| Item | Cost |
|------|------|
| CMK (per month) | $1.00 |
| API requests (per 10,000) | $0.03 |
| Automatic rotation | Free (included) |
| Imported key material | Same as CMK |
| CloudHSM-backed key | $1.00 + CloudHSM cluster ($1.60/hr) |

Our projected cost: **~$1/month** (1 CMK + minimal API calls).

## Key Concepts

- SSE-S3, SSE-KMS, SSE-C, and DSSE-KMS differ by who manages the key — SSE-KMS is the right choice when you need audit trails or cross-account access
- Key policy + IAM policy interaction: key policy is evaluated first; IAM policies alone can't override it
- Use CMK over AWS managed key when you need cross-account access, a custom key policy, or rotation control
- Envelope encryption is the standard pattern — KMS encrypts the data key, not the data itself
- Multi-region keys replicate the same key material to other regions; useful for active-active or DR setups
- KMS has a per-account request quota (5,500–30,000 req/sec by region/key type) — use data key caching or S3 bucket keys if you approach it
- `kms:ViaService` condition key restricts CMK usage to specific AWS services
- `aws:kms:dsse` (dual-layer SSE) is required for certain compliance frameworks
