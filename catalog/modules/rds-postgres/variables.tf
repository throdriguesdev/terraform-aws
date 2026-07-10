variable "identifier" {
  description = "Unique name for the RDS instance"
  type        = string
}

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "app"
}

variable "master_username" {
  description = "Master DB username"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.14"
}

variable "instance_class" {
  description = "RDS instance class (db.t3.micro = free tier eligible)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial storage in GB (free tier gives 20GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max storage for autoscaling in GB (0 = disabled)"
  type        = number
  default     = 100
}

variable "vpc_id" {
  description = "VPC ID where the instance is deployed"
  type        = string
}

variable "subnet_ids" {
  description = "Database subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDRs allowed to reach port 5432 — typically the VPC CIDR"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for storage encryption (null = AWS managed key)"
  type        = string
  default     = null
}

variable "multi_az" {
  description = "Enable Multi-AZ standby replica"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Days to retain automated backups (free tier max = 1)"
  type        = number
  default     = 1
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy — set false for prod"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Prevent accidental instance deletion"
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights (free for 7-day retention)"
  type        = bool
  default     = true
}
