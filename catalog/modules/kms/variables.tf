variable "alias" {
  description = "KMS key alias (without alias/ prefix)"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction"
  type        = number
  default     = 7
}

variable "enable_key_rotation" {
  description = "Enable automatic annual key rotation"
  type        = bool
  default     = true
}

variable "account_id" {
  description = "AWS account ID for the key policy root principal — defaults to the current caller's account"
  type        = string
  default     = null
}
