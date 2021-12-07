module "http" {
  count  = local.http == null ? 0 : 1
  source = "./http"

  prefix         = local.prefix
  domain         = local.domain_http
  allow_origins  = local.redirect_urls
  hosted_zone_id = concat(data.aws_route53_zone.domain.*.zone_id, [null])[0]
  auth_module    = concat(module.auth, [null])[0]

  source_dir  = local.http.source_dir
  timeout     = local.http.timeout
  memory_size = local.http.memory_size
  runtime     = local.http.runtime
  handler     = local.http.handler

  environment = local.http.environment

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}
