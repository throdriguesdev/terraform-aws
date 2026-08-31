output "zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "Zone name"
  value       = aws_route53_zone.this.name
}

output "name_servers" {
  description = "NS records to delegate in Vercel — add these as NS records for the subdomain"
  value       = aws_route53_zone.this.name_servers
}
