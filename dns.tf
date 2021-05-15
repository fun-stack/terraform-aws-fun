data "aws_route53_zone" "domain" {
  name = var.domain
}

resource "aws_acm_certificate" "website" {
  domain_name       = local.domain_website
  validation_method = "DNS"
  provider          = aws.us
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.domain.zone_id
}

resource "aws_acm_certificate_validation" "website" {
  certificate_arn = aws_acm_certificate.website.arn
  validation_record_fqdns = [
    for dvo in aws_acm_certificate.website.domain_validation_options : aws_route53_record.certificate_validation[dvo.domain_name].fqdn
  ]
  provider = aws.us
}
