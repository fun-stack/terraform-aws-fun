output "ws_rpc_role" {
  value = one(module.ws[*].rpc_role)
}

output "http_api_role" {
  value = one(module.http[*].api_role)
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
