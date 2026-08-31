variable "zone_name" {
  description = "DNS zone name (e.g. lab.trdevops.com.br)"
  type        = string
}

variable "comment" {
  description = "Zone comment"
  type        = string
  default     = ""
}

variable "private_vpc_id" {
  description = "VPC ID to associate for a private hosted zone — null creates a public zone"
  type        = string
  default     = null
}
