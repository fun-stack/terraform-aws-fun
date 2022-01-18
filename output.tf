output "ws_role" {
  value = concat(module.ws[*].ws_role, [null])[0]
}

output "http_role" {
  value = concat(module.http[*].http_role, [null])[0]
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
  value = concat(data.aws_route53_zone.domain.*.zone_id, [null])[0]
}
