output "function" {
  value = aws_lambda_function.lambda
}

output "function_name" {
  value = local.prefix
}

output "role" {
  value = aws_iam_role.lambda
}
