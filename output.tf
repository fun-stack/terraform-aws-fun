output "api_role" {
  value = concat(module.api[*].api_role, [null])[0]
}

output "http_role" {
  value = concat(module.http[*].http_role, [null])[0]
}

output "prefix" {
  value = local.prefix
}
