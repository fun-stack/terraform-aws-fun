module "ws" {
  count  = local.ws == null ? 0 : 1
  source = "./ws"

  prefix                = local.prefix
  domain                = local.domain_ws
  hosted_zone_id        = concat(data.aws_route53_zone.domain[*].zone_id, [null])[0]
  auth_module           = concat(module.auth, [null])[0]
  allow_unauthenticated = local.ws.allow_unauthenticated

  source_dir    = local.ws.source_dir
  source_bucket = local.ws.source_bucket
  timeout       = local.ws.timeout
  memory_size   = local.ws.memory_size
  runtime       = local.ws.runtime
  handler       = local.ws.handler

  environment = local.ws.environment

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}
