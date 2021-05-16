data "aws_route53_zone" "domain" {
  name = var.domain
}

resource "aws_acm_certificate" "website" {
  domain_name       = local.domain_website
  validation_method = "DNS"
  provider          = aws.us
}

resource "aws_route53_record" "certificate_validation_website" {
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
    for dvo in aws_acm_certificate.website.domain_validation_options : aws_route53_record.certificate_validation_website[dvo.domain_name].fqdn
  ]
  provider = aws.us
}

resource "aws_acm_certificate" "website_www" {
  domain_name       = "www.${local.domain_website}"
  validation_method = "DNS"
  provider          = aws.us
}

resource "aws_route53_record" "certificate_validation_website_www" {
  for_each = {
    for dvo in aws_acm_certificate.website_www.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "website_www" {
  certificate_arn = aws_acm_certificate.website_www.arn
  validation_record_fqdns = [
    for dvo in aws_acm_certificate.website_www.domain_validation_options : aws_route53_record.certificate_validation_website_www[dvo.domain_name].fqdn
  ]
  provider = aws.us
}
