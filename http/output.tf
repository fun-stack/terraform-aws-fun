output "http_role" {
  value = aws_iam_role.lambda_http
}

output "endpoint" {
  value = "${replace(aws_apigatewayv2_api.httpapi.api_endpoint, "https://", "")}/latest"
}
