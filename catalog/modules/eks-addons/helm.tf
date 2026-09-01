################################################################################
# AWS Load Balancer Controller
################################################################################

resource "helm_release" "lbc" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = var.lbc_chart_version
  namespace        = var.lbc_namespace
  create_namespace = false

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "region"
    value = var.region
  }
  set {
    name  = "vpcId"
    value = var.vpc_id
  }
  set {
    name  = "serviceAccount.name"
    value = var.lbc_sa_name
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lbc[0].arn
  }
  set {
    name  = "replicaCount"
    value = "2"
  }

  wait    = true
  timeout = 300

  depends_on = [aws_iam_role_policy.lbc]
}

################################################################################
# cert-manager
################################################################################

resource "helm_release" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  namespace        = var.cert_manager_namespace
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = var.cert_manager_sa_name
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager[0].arn
  }
  set {
    name  = "extraArgs[0]"
    value = "--issuer-ambient-credentials"
  }

  depends_on = [aws_iam_role_policy.cert_manager]
}

################################################################################
# external-dns
################################################################################

resource "helm_release" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = var.external_dns_chart_version
  namespace        = var.external_dns_namespace
  create_namespace = true

  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "aws.region"
    value = var.region
  }
  set {
    name  = "aws.zoneType"
    value = var.external_dns_zone_type
  }
  set {
    name  = "domainFilters[0]"
    value = var.dns_zone
  }
  set {
    name  = "policy"
    value = "upsert-only"
  }
  set {
    name  = "txtOwnerId"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.name"
    value = var.external_dns_sa_name
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns[0].arn
  }

  depends_on = [aws_iam_role_policy.external_dns]
}

################################################################################
# external-secrets
################################################################################

resource "helm_release" "external_secrets" {
  count = var.enable_external_secrets ? 1 : 0

  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.external_secrets_chart_version
  namespace        = var.external_secrets_namespace
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = var.external_secrets_sa_name
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets[0].arn
  }

  depends_on = [aws_iam_role_policy.external_secrets, helm_release.lbc]
}
