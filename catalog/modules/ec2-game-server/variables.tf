variable "name" {
  description = "Resource name prefix"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (c6a.xlarge = 4vCPU/8GB, good for ~8 players)"
  type        = string
  default     = "c6a.xlarge"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 30
}

variable "server_name" {
  description = "PZ server name (used for config file and -servername arg)"
  type        = string
  default     = "pzserver"
}

variable "admin_password" {
  description = "PZ admin password"
  type        = string
  sensitive   = true
}
