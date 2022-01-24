output "ws_role" {
  value = aws_iam_role.lambda_ws
}

output "url" {
  value = "${replace(aws_apigatewayv2_api.websocket.api_endpoint, "https://", "wss://")}/latest"
}

output "connections_table" {
  value = aws_dynamodb_table.websocket_connections.id
}

output "connections_policy_arn" {
  value = aws_iam_policy.websocket_connections.arn
}
