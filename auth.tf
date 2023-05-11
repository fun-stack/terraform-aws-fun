module "auth" {
  count  = var.auth == null ? 0 : 1
  source = "./auth"

  prefix                  = local.prefix
  log_retention_in_days   = var.logging.retention_in_days
  admin_registration_only = var.auth.admin_registration_only

  domain         = local.domain_auth
  hosted_zone_id = one(data.aws_route53_zone.domain[*].zone_id)

  post_authentication_trigger = var.auth.post_authentication_trigger
  post_confirmation_trigger   = var.auth.post_confirmation_trigger
  pre_authentication_trigger  = var.auth.pre_authentication_trigger
  pre_sign_up_trigger         = var.auth.pre_sign_up_trigger

  depends_on = [
    //TODO: only because cognito on a subdomain only works if the main domain
    //has an a record, e.g. from the website. But takes longer to delay this
    //whole module.
    module.website
  ]

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
