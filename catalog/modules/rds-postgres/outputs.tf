output "identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.identifier
}

output "endpoint" {
  description = "Connection endpoint (host:port)"
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Hostname only"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Name of the default database"
  value       = aws_db_instance.this.db_name
}

output "master_username" {
  description = "Master username"
  value       = aws_db_instance.this.username
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the master password — grant IRSA access to this"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "security_group_id" {
  description = "Security group ID — add ingress rules to allow additional sources"
  value       = aws_security_group.this.id
}

output "instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}
