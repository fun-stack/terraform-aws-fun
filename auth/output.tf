output "user_pool_client" {
  value = aws_cognito_user_pool_client.website_client
}

output "api_scopes" {
  value = aws_cognito_resource_server.user.scope_identifiers
}

output "user_pool" {
  value = aws_cognito_user_pool.user
}

output "get_info_policy_arn" {
  value = aws_iam_policy.get_info.arn
}

output "url" {
  value = var.domain == null ? "https://${aws_cognito_user_pool_domain.user.domain}.auth.${data.aws_region.current.name}.amazoncognito.com" : "https://${var.domain}"
}
