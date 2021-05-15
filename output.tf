output "api_role" {
  value = concat(module.api[*].api_role, [null])[0]
}
