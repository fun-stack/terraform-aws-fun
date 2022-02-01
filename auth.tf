module "auth" {
  count  = local.auth == null ? 0 : 1
  source = "./auth"

  prefix = local.prefix

  css_file   = local.auth.css_file
  image_file = local.auth.image_file

  domain         = local.domain_auth
  hosted_zone_id = one(data.aws_route53_zone.domain[*].zone_id)

  redirect_urls = local.redirect_urls

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}
