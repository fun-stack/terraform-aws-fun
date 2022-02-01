module "http" {
  count  = local.http == null ? 0 : 1
  source = "./http"

  prefix                = local.prefix
  log_retention_in_days = local.logging.retention_in_days

  domain                = local.domain_http
  allow_origins         = local.redirect_urls
  hosted_zone_id        = one(data.aws_route53_zone.domain[*].zone_id)
  auth_module           = one(module.auth)
  allow_unauthenticated = local.http.allow_unauthenticated

  api = lookup(local.http, "api", null) == null ? null : merge(local.http.api, {
    environment = merge(
      local.http.api.environment == null ? {} : local.http.api.environment,
      length(module.ws) == 0 ? {} : {
        FUN_EVENTS_SNS_OUTPUT_TOPIC = module.ws[0].event_topic
      },
      length(module.auth) == 0 ? {} : {
        FUN_AUTH_COGNITO_USER_POOL_ID = module.auth[0].user_pool.id
      }
    )
  })

  rpc = lookup(local.http, "rpc", null) == null ? null : merge(local.http.rpc, {
    environment = merge(
      local.http.rpc.environment == null ? {} : local.http.rpc.environment,
      length(module.ws) == 0 ? {} : {
        FUN_EVENTS_SNS_OUTPUT_TOPIC = module.ws[0].event_topic
      },
      length(module.auth) == 0 ? {} : {
        FUN_AUTH_COGNITO_USER_POOL_ID = module.auth[0].user_pool.id
      }
    )
  })

  providers = {
    aws = aws
  }
}

resource "aws_iam_role_policy_attachment" "lambda_http_api_events" {
  count      = length(module.ws) > 0 && length(module.http) > 0 ? (module.http[0].api_role != null ? 1 : 0) : 0
  role       = module.http[count.index].api_role.name
  policy_arn = module.ws[0].event_policy_arn
}

resource "aws_iam_role_policy_attachment" "lambda_http_api_auth_get_info" {
  count      = length(module.auth) > 0 && length(module.http) > 0 ? (module.http[0].api_role != null ? 1 : 0) : 0
  role       = module.http[count.index].api_role.name
  policy_arn = module.auth[0].get_info_policy_arn
}

resource "aws_iam_role_policy_attachment" "lambda_http_rpc_events" {
  count      = length(module.ws) > 0 && length(module.http) > 0 ? (module.http[0].rpc_role != null ? 1 : 0) : 0
  role       = module.http[count.index].rpc_role.name
  policy_arn = module.ws[0].event_policy_arn
}

resource "aws_iam_role_policy_attachment" "lambda_http_rpc_auth_get_info" {
  count      = length(module.auth) > 0 && length(module.http) > 0 ? (module.http[0].rpc_role != null ? 1 : 0) : 0
  role       = module.http[count.index].rpc_role.name
  policy_arn = module.auth[0].get_info_policy_arn
}
