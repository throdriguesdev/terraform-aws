resource "aws_route53_zone" "this" {
  name    = var.zone_name
  comment = var.comment

  dynamic "vpc" {
    for_each = var.private_vpc_id != null ? [1] : []
    content {
      vpc_id = var.private_vpc_id
    }
  }
}
