resource "aws_iam_policy" "websocket_connections" {
  name = "${local.prefix}-websocket-connections"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:ConditionCheckItem"
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.websocket_connections.arn,
          "${aws_dynamodb_table.websocket_connections.arn}/index/${local.websocket_connections_index_name}"
        ]
      },
      {
        Action = [
          "execute-api:Invoke",
          "execute-api:ManageConnections"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_apigatewayv2_api.websocket.execution_arn}/*"
        ]
      },
    ]
  })
}
