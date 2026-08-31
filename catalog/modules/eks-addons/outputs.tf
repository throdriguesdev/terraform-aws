output "lbc_role_arn" {
  description = "IRSA role ARN for AWS Load Balancer Controller"
  value       = var.enable_aws_load_balancer_controller ? aws_iam_role.lbc[0].arn : null
}

output "cert_manager_role_arn" {
  description = "IRSA role ARN for cert-manager"
  value       = var.enable_cert_manager ? aws_iam_role.cert_manager[0].arn : null
}

output "external_dns_role_arn" {
  description = "IRSA role ARN for external-dns"
  value       = var.enable_external_dns ? aws_iam_role.external_dns[0].arn : null
}

output "external_secrets_role_arn" {
  description = "IRSA role ARN for external-secrets"
  value       = var.enable_external_secrets ? aws_iam_role.external_secrets[0].arn : null
}
