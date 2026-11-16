
locals {
  app_domain = "${var.app_subdomain}.${var.domain_name}"
  api_domain = "${var.api_subdomain}.${var.domain_name}"
}

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "nexora-uat-tf-state-backend"
    key    = "dns/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_route53_record" "nexora" {
  zone_id = data.terraform_remote_state.dns.outputs.zone_id
  name    = local.app_domain
  type    = "A"

  alias {
    name                   = aws_lb.nexora.dns_name
    zone_id                = aws_lb.nexora.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "nexora_api" {
  zone_id = data.terraform_remote_state.dns.outputs.zone_id
  name    = local.api_domain
  type    = "A"

  alias {
    name                   = aws_lb.nexora.dns_name
    zone_id                = aws_lb.nexora.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "nexora" {
  domain_name = local.app_domain

  subject_alternative_names = [
    local.api_domain
  ]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.nexora.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.terraform_remote_state.dns.outputs.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "nexora" {
  certificate_arn = aws_acm_certificate.nexora.arn

  validation_record_fqdns = [
    for record in aws_route53_record.acm_validation :
    record.fqdn
  ]

  timeouts {
    create = "30m"
  }
}