output "ws_role" {
  value = concat(module.ws[*].ws_role, [null])[0]
}

output "http_role" {
  value = concat(module.http[*].http_role, [null])[0]
}

output "prefix" {
  value = local.prefix
}

output "domain_website" {
  value = local.domain_website_real
}

output "domain_http" {
  value = local.domain_http_real
}

output "domain_ws" {
  value = local.domain_ws_real
}

output "domain_auth" {
  value = local.domain_auth_real
}

output "hosted_zone_id" {
  value = concat(data.aws_route53_zone.domain.*.zone_id, [null])[0]
}
