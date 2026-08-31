variable "cluster_name" {
  description = "EKS cluster name — used for labelling"
  type        = string
}

variable "ingress_host" {
  description = "Hostname for the ArgoCD UI (e.g. argocd.lab.trdevops.com.br)"
  type        = string
}

variable "chart_version" {
  description = "argo-cd Helm chart version"
  type        = string
  default     = "7.7.3"
}

variable "gitops_repo_url" {
  description = "Git repository URL that ArgoCD will manage (used as a label/annotation)"
  type        = string
  default     = ""
}
