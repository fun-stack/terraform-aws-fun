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

  environment = merge(
    local.ws.environment == null ? {} : local.ws.environment,
    module.auth == null ? {} : {
      FUN_AUTH_COGNITO_POOL_ID = module.auth[0].user_pool.id
    }
  )

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}

resource "aws_iam_role_policy_attachment" "lambda_ws_auth_get_info" {
  count      = module.auth == null || module.ws == null ? 0 : 1
  role       = module.ws[0].ws_role.name
  policy_arn = module.auth[0].get_info_policy_arn
}
