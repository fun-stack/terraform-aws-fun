module "auth" {
  count  = local.auth == null ? 0 : 1
  source = "./auth"

  prefix                = local.prefix
  log_retention_in_days = local.logging.retention_in_days

  css_file   = local.auth.css_file
  image_file = local.auth.image_file

  domain         = local.domain_auth
  hosted_zone_id = one(data.aws_route53_zone.domain[*].zone_id)

  redirect_urls = local.redirect_urls

  post_authentication_trigger = local.auth.post_authentication_trigger
  post_confirmation_trigger   = local.auth.post_confirmation_trigger
  pre_authentication_trigger  = local.auth.pre_authentication_trigger
  pre_sign_up_trigger         = local.auth.pre_sign_up_trigger

  providers = {
    aws    = aws
    aws.us-east-1 = aws.us-east-1
  }
}
