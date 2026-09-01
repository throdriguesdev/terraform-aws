variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster OIDC provider"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL (with https://)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID — passed to the AWS Load Balancer Controller"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "dns_zone" {
  description = "Route53 zone managed by external-dns (e.g. lab.trdevops.com.br)"
  type        = string
}

variable "enable_aws_load_balancer_controller" {
  description = "Deploy the AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Deploy cert-manager with Route53 DNS01 solver IRSA"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Deploy external-dns scoped to var.dns_zone"
  type        = bool
  default     = true
}

variable "enable_external_secrets" {
  description = "Deploy external-secrets operator with SSM/SecretsManager IRSA"
  type        = bool
  default     = true
}

variable "lbc_namespace" {
  description = "Kubernetes namespace for the AWS Load Balancer Controller"
  type        = string
  default     = "kube-system"
}

variable "lbc_sa_name" {
  description = "Service account name for the AWS Load Balancer Controller — must match the IRSA trust policy"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "cert_manager_namespace" {
  description = "Kubernetes namespace for cert-manager"
  type        = string
  default     = "cert-manager"
}

variable "cert_manager_sa_name" {
  description = "Service account name for cert-manager — must match the IRSA trust policy"
  type        = string
  default     = "cert-manager"
}

variable "external_dns_namespace" {
  description = "Kubernetes namespace for external-dns"
  type        = string
  default     = "external-dns"
}

variable "external_dns_sa_name" {
  description = "Service account name for external-dns — must match the IRSA trust policy"
  type        = string
  default     = "external-dns"
}

variable "external_dns_zone_type" {
  description = "Route53 zone type for external-dns to manage (public or private)"
  type        = string
  default     = "public"
}

variable "external_secrets_namespace" {
  description = "Kubernetes namespace for external-secrets"
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_sa_name" {
  description = "Service account name for external-secrets — must match the IRSA trust policy"
  type        = string
  default     = "external-secrets"
}

variable "external_secrets_secret_arns" {
  description = "Secrets Manager secret ARNs the external-secrets role may read — defaults to all secrets in the account"
  type        = list(string)
  default     = ["*"]
}

variable "external_secrets_parameter_arns" {
  description = "SSM Parameter Store ARNs the external-secrets role may read — defaults to all parameters in the account"
  type        = list(string)
  default     = ["*"]
}

variable "external_secrets_kms_key_arns" {
  description = "KMS key ARNs the external-secrets role may use for decryption — defaults to all keys in the account"
  type        = list(string)
  default     = ["*"]
}

variable "lbc_chart_version" {
  description = "Helm chart version for aws-load-balancer-controller"
  type        = string
  default     = "1.8.1"
}

variable "cert_manager_chart_version" {
  description = "Helm chart version for cert-manager"
  type        = string
  default     = "v1.14.5"
}

variable "external_dns_chart_version" {
  description = "Helm chart version for external-dns"
  type        = string
  default     = "1.14.4"
}

variable "external_secrets_chart_version" {
  description = "Helm chart version for external-secrets"
  type        = string
  default     = "0.9.11"
}
