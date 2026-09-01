variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.36"
}

variable "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for control plane and node group"
  type        = list(string)
}

variable "instance_types" {
  description = "EC2 instance types for the default node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "kms_key_arn" {
  description = "KMS key ARN for Kubernetes secrets encryption (null = unencrypted)"
  type        = string
  default     = null
}

variable "enabled_cluster_log_types" {
  description = "Control plane log types to send to CloudWatch: api, audit, authenticator, controllerManager, scheduler"
  type        = list(string)
  default     = []
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint — empty list means no public access restriction is set by default; restrict to specific IPs in production"
  type        = list(string)
  default     = []
}

variable "ami_type" {
  description = "AMI type for the managed node group (e.g. AL2023_x86_64_STANDARD, AL2023_ARM_64_STANDARD, BOTTLEROCKET_x86_64)"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_max_unavailable" {
  description = "Maximum number of nodes unavailable during a node group update"
  type        = number
  default     = 1
}

variable "region" {
  description = "AWS region — used in helper outputs"
  type        = string
}

variable "authentication_mode" {
  description = "EKS auth mode: API_AND_CONFIG_MAP (default, keeps aws-auth CM) or API (access entries only)"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "capacity_type" {
  description = "ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "enable_ebs_csi" {
  description = "Install the EBS CSI driver addon with its IRSA role"
  type        = bool
  default     = true
}
