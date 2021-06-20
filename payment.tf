module "payment" {
  count  = local.payment == null ? 0 : 1
  source = "./payment"

  prefix         = local.prefix
  domain         = local.domain_payment
  hosted_zone_id = data.aws_route53_zone.domain.zone_id
  auth_module    = concat(module.auth, [null])[0]

  stripe_api_token_private = local.payment.stripe_api_token_private
  stripe_api_token_public  = local.payment.stripe_api_token_public
  product                  = local.payment.product
  prices                   = local.payment.prices

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}
