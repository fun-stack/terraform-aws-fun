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

  post_authentication_trigger = local.auth.lambda_trigger.post_authentication
  post_confirmation_trigger   = local.auth.lambda_trigger.post_confirmation
  pre_authentication_trigger  = local.auth.lambda_trigger.pre_authentication
  pre_sign_up_trigger         = local.auth.lambda_trigger.pre_sign_up

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}
