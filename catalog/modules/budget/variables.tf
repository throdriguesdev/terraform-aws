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
