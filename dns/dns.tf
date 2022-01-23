resource "aws_acm_certificate" "domain" {
  domain_name               = var.domain
  subject_alternative_names = [for d in var.sub_domains : "${d}.${var.domain}"]
  validation_method         = "DNS"

  // TODO: Needed for https://github.com/hashicorp/terraform-provider-aws/issues/20957
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "dns_caa" {
  name    = var.domain
  type    = "CAA"
  zone_id = var.hosted_zone_id
  ttl     = 60

  records = ["0 issue \"amazonaws.com\""]
}


resource "aws_route53_record" "certificate_validation_domain" {
  for_each = {
    for dvo in aws_acm_certificate.domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "domain" {
  certificate_arn = aws_acm_certificate.domain.arn
  validation_record_fqdns = [
    for dvo in aws_acm_certificate.domain.domain_validation_options : aws_route53_record.certificate_validation_domain[dvo.domain_name].fqdn
  ]
}
