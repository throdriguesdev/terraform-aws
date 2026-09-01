variable "limit_amount" {
  description = "Budget limit in USD"
  type        = string
}

variable "notification_email" {
  description = "Email address for budget notifications"
  type        = string
}

variable "thresholds" {
  description = "List of percentage thresholds to trigger notifications"
  type        = list(number)
  default     = [25, 50, 75, 100]
}

variable "environment" {
  description = "Environment name appended to resource names to avoid conflicts across deployments (e.g. dev, staging, prod)"
  type        = string
  default     = ""
}
