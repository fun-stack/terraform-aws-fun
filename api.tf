module "api" {
  count  = local.api == null ? 0 : 1
  source = "./api"

  prefix         = local.prefix
  domain         = local.domain_ws
  hosted_zone_id = concat(data.aws_route53_zone.domain.*.zone_id, [null])[0]
  auth_module    = concat(module.auth, [null])[0]

  source_dir  = local.api.source_dir
  timeout     = local.api.timeout
  memory_size = local.api.memory_size
  runtime     = local.api.runtime
  handler     = local.api.handler

  environment = local.api.environment

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}
