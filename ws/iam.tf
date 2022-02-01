resource "aws_iam_role" "websocket" {
  name = "${local.prefix}-api"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "websocket" {
  role = aws_iam_role.websocket.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = [
          aws_dynamodb_table.websocket_subscriptions.arn
        ]
      },
      {
        Action = [
          "sns:publish",
        ]
        Effect = "Allow"
        Resource = [
          aws_sns_topic.connection_deletion.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = concat(module.lambda_rpc[*].function.arn, module.authorizer[*].function.arn)
      }
    ]
  })
}

resource "aws_iam_policy" "subscription_events" {
  name = "${local.prefix}-subscription-events"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:publish",
        ]
        Effect = "Allow"
        Resource = [
          aws_sns_topic.subscription_events.arn
        ]
      },
    ]
  })
}
