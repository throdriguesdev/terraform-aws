variable "alias" {
  description = "KMS key alias (without alias/ prefix)"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction"
  type        = number
  default     = 7
}
