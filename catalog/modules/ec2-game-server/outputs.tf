output "public_ip" {
  description = "Elastic IP — give this to players"
  value       = aws_eip.this.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "security_group_id" {
  value = aws_security_group.this.id
}
