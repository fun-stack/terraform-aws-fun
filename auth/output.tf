output "user_pool_client" {
  value = aws_cognito_user_pool_client.website_client
}

output "user_pool" {
  value = aws_cognito_user_pool.user
}

output "authorizer_lambda" {
  value = aws_lambda_function.authorizer
}

output "endpoint" {
  value = var.domain == null ? "${aws_cognito_user_pool_domain.user.domain}.auth.${data.aws_region.current.name}.amazoncognito.com" : var.domain
}
