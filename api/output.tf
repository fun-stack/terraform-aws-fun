output "api_role" {
  value = aws_iam_role.lambda_api
}

output "endpoint" {
  value = "${replace(aws_apigatewayv2_api.websocket.api_endpoint, "https://", "")}/latest"
}
