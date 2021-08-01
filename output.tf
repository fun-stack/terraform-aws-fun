output "api_role" {
  value = concat(module.api[*].api_role, [null])[0]
}

output "http_role" {
  value = concat(module.http[*].http_role, [null])[0]
}

output "prefix" {
  value = local.prefix
}

output "domain_website" {
  value = local.domain_website
}

output "domain_http" {
  value = local.domain_http
}

output "domain_ws" {
  value = local.domain_ws
}

output "domain_auth" {
  value = local.domain_auth
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.domain.zone_id
}
