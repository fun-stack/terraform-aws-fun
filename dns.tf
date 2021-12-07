module "dns" {
  count  = local.domain == null ? 0 : 1
  source = "./dns"

  domain         = local.domain
  sub_domains    = ["www"]
  hosted_zone_id = concat(data.aws_route53_zone.domain.*.zone_id, [null])[0]

  providers = {
    aws = aws.us
  }
}
