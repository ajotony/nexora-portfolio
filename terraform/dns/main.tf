variable "domain_name" {
  description = "Root domain managed through Route 53."
  type        = string
}

resource "aws_route53_zone" "main" {
  name = var.domain_name

  lifecycle {
    prevent_destroy = true
  }
}

output "zone_id" {
  description = "Persistent Route 53 hosted zone ID."
  value       = aws_route53_zone.main.zone_id
}

output "zone_name" {
  description = "Persistent DNS domain."
  value       = aws_route53_zone.main.name
}

output "name_servers" {
  description = "Route 53 authoritative nameservers."
  value       = aws_route53_zone.main.name_servers
}