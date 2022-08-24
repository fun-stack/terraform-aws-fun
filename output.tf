output "ws_rpc_role" {
  value = one(module.ws[*].rpc_role)
}

output "http_api_role" {
  value = one(module.http[*].api_role)
}

output "auth_post_confirmation_trigger_role" {
  value = one(module.auth[*].post_confirmation_trigger_role)
}

output "auth_post_authentication_trigger_role" {
  value = one(module.auth[*].post_authentication_trigger_role)
}

output "auth_pre_authentication_trigger_role" {
  value = one(module.auth[*].pre_authentication_trigger_role)
}

output "auth_pre_sign_up_trigger_role" {
  value = one(module.auth[*].pre_sign_up_trigger_role)
}

output "auth_cognito_user_pool_id" {
  value = one(module.auth[*].user_pool.id)
}

output "prefix" {
  value = local.prefix
}

output "url_website" {
  value = local.url_website
}

output "url_http" {
  value = local.url_http
}

output "url_ws" {
  value = local.url_ws
}

output "url_auth" {
  value = local.url_auth
}

output "hosted_zone_id" {
  value = one(data.aws_route53_zone.domain[*].zone_id)
}

output "app_config" {
  value = local.app_config_js
}

output "backend_environment_vars" {
  value = merge(
    length(module.ws) == 0 ? {} : {
      FUN_EVENTS_SNS_OUTPUT_TOPIC = module.ws[0].event_topic
    },
    length(module.auth) == 0 ? {} : {
      FUN_AUTH_COGNITO_USER_POOL_ID = module.auth[0].user_pool.id
    }
  )
}

output "backend_policy_arn" {
  value = one(module.ws[*].event_policy_arn)
}
