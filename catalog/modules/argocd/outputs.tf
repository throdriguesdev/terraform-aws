output "namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = helm_release.argocd.namespace
}

output "ingress_host" {
  description = "ArgoCD UI hostname"
  value       = var.ingress_host
}
