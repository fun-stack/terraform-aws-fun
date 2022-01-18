output "ws_role" {
  value = aws_iam_role.lambda_ws
}

output "url" {
  value = "${replace(aws_apigatewayv2_api.websocket.api_endpoint, "https://", "wss://")}/latest"
}
