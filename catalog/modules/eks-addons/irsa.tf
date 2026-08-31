locals {
  oidc_issuer = trimprefix(var.oidc_issuer_url, "https://")
}

################################################################################
# AWS Load Balancer Controller
#
# Permissions use the canonical upstream policy (policies/lbc-iam-policy.json,
# pinned to the controller version) rather than a hand-maintained inline policy —
# the upstream policy correctly handles both the elbv2.k8s.aws/cluster and
# ingress.k8s.aws/* resource tags, including DeleteLoadBalancer on teardown.
################################################################################

resource "aws_iam_role" "lbc" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0
  name  = "${var.cluster_name}-lbc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "lbc" {
  count  = var.enable_aws_load_balancer_controller ? 1 : 0
  name   = "${var.cluster_name}-lbc-policy"
  role   = aws_iam_role.lbc[0].id
  policy = file("${path.module}/policies/lbc-iam-policy.json")
}

################################################################################
# cert-manager — Route53 DNS01 solver
################################################################################

resource "aws_iam_role" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0
  name  = "${var.cluster_name}-cert-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:sub" = "system:serviceaccount:cert-manager:cert-manager"
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0
  name  = "${var.cluster_name}-cert-manager-policy"
  role  = aws_iam_role.cert_manager[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:GetChange"]
        Resource = "arn:aws:route53:::change/*"
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets", "route53:ListResourceRecordSets"]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZonesByName"]
        Resource = "*"
      },
    ]
  })
}

################################################################################
# external-dns
################################################################################

resource "aws_iam_role" "external_dns" {
  count = var.enable_external_dns ? 1 : 0
  name  = "${var.cluster_name}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:sub" = "system:serviceaccount:external-dns:external-dns"
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "external_dns" {
  count = var.enable_external_dns ? 1 : 0
  name  = "${var.cluster_name}-external-dns-policy"
  role  = aws_iam_role.external_dns[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["route53:ChangeResourceRecordSets"]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZones", "route53:ListResourceRecordSets", "route53:ListTagsForResource"]
        Resource = "*"
      },
    ]
  })
}

################################################################################
# external-secrets — SSM + Secrets Manager read
################################################################################

resource "aws_iam_role" "external_secrets" {
  count = var.enable_external_secrets ? 1 : 0
  name  = "${var.cluster_name}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          "${local.oidc_issuer}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "external_secrets" {
  count = var.enable_external_secrets ? 1 : 0
  name  = "${var.cluster_name}-external-secrets-policy"
  role  = aws_iam_role.external_secrets[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = "*"
      },
    ]
  })
}
