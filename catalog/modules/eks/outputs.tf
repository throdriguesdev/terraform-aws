output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded certificate authority data"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group attached to the EKS control plane"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_group_role_arn" {
  description = "ARN of the IAM role used by the default node group"
  value       = aws_iam_role.node_group.arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL — used to build IRSA trust policies"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider — used in IRSA assume-role policies"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "ebs_csi_role_arn" {
  description = "ARN of the EBS CSI driver IRSA role"
  value       = var.enable_ebs_csi ? aws_iam_role.ebs_csi[0].arn : null
}

output "kubeconfig_command" {
  description = "Run this after apply to update your local kubeconfig"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region ${var.region}"
}
