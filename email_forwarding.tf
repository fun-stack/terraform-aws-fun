resource "aws_route53_record" "email_mx" {
  count = var.domain == null ? 0 : (var.domain.catch_all_email == null ? 0 : 1)

  name = local.domain_website
  records = [
    "10 mx1.forwardemail.net",
    "20 mx2.forwardemail.net",
  ]
  ttl     = 60
  type    = "MX"
  zone_id = data.aws_route53_zone.domain[0].zone_id
}

resource "aws_route53_record" "email_txt" {
  count = var.domain == null ? 0 : (var.domain.catch_all_email == null ? 0 : 1)

  name = local.domain_website
  records = [
    "forward-email=${var.domain.catch_all_email}",
    "v=spf1 a mx include:spf.forwardemail.net ~all",
  ]
  ttl     = 60
  type    = "TXT"
  zone_id = data.aws_route53_zone.domain[0].zone_id
}
