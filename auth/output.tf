output "user_pool_client" {
  value = aws_cognito_user_pool_client.website_client
}

output "identity_pool" {
  value = aws_cognito_identity_pool.user
}

output "user_pool" {
  value = aws_cognito_user_pool.user
}

output "authorizer_lambda" {
  value = aws_lambda_function.authorizer
}
