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

output "idp_url" {
  value = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.user.id}"
}

output "post_confirmation_trigger_role" {
  value = one(module.lambda_post_confirmation[*].role)
}

output "post_authentication_trigger_role" {
  value = one(module.lambda_post_authentication[*].role)
}

output "pre_authentication_trigger_role" {
  value = one(module.lambda_pre_authentication[*].role)
}

output "pre_sign_up_trigger_role" {
  value = one(module.lambda_pre_sign_up[*].role)
}
