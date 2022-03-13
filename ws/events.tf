// topics
# TODO: FIFO? message-group by subscription-key. But throughput only 300 transactions per second
# fifo_topic = true
resource "aws_sns_topic" "subscription_events" {
  name = "${local.prefix}-subscription-events"
}

resource "aws_sns_topic" "connection_events" {
  name = "${local.prefix}-connection-events"
}

resource "aws_sns_topic" "connection_events_authorized" {
  count = var.event_authorizer == null ? 0 : 1
  name  = "${local.prefix}-connection-events-authorized"
}

resource "aws_sns_topic" "connection_deletion" {
  name = "${local.prefix}-subscription-delete"
}

resource "aws_sns_topic_subscription" "event_expander" {
  topic_arn = aws_sns_topic.subscription_events.arn
  protocol  = "lambda"
  endpoint  = module.lambda_event_expander.function.arn
}

resource "aws_sns_topic_subscription" "event_sender" {
  topic_arn = var.event_authorizer == null ? aws_sns_topic.connection_events.arn : aws_sns_topic.connection_events_authorized[0].arn
  protocol  = "lambda"
  endpoint  = module.lambda_event_sender.function.arn
}

resource "aws_sns_topic_subscription" "event_authorizer" {
  count     = var.event_authorizer == null ? 0 : 1
  topic_arn = aws_sns_topic.connection_events.arn
  protocol  = "lambda"
  endpoint  = module.lambda_event_authorizer[0].function.arn
}

resource "aws_sns_topic_subscription" "subscription_cleanup" {
  topic_arn = aws_sns_topic.connection_deletion.arn
  protocol  = "lambda"
  endpoint  = module.lambda_subscription_cleanup.function.arn
}

// lambda

module "lambda_event_expander" {
  source = "../lambda"

  prefix                = "${local.prefix}-event-expander"
  log_retention_in_days = var.log_retention_in_days

  source_dir  = "${path.module}/../src/event_expander/build/"
  timeout     = 60
  memory_size = 256
  runtime     = "nodejs14.x"
  handler     = "index.handler"

  environment = {
    DYNAMO_SUBSCRIPTIONS_TABLE = aws_dynamodb_table.websocket_subscriptions.id
    SNS_INPUT_TOPIC            = aws_sns_topic.subscription_events.id
    SNS_OUTPUT_TOPIC           = aws_sns_topic.connection_events.id
  }

  secrets = null
}

module "lambda_event_sender" {
  source = "../lambda"

  prefix                = "${local.prefix}-event-sender"
  log_retention_in_days = var.log_retention_in_days

  source_dir  = "${path.module}/../src/event_sender/build/"
  timeout     = 30
  memory_size = 128
  runtime     = "nodejs14.x"
  handler     = "index.handler"

  environment = {
    API_GATEWAY_ENDPOINT = replace(local.api_gateway_url, "wss://", "")
  }

  secrets = null
}

module "lambda_event_authorizer" {
  count  = var.event_authorizer == null ? 0 : 1
  source = "../lambda"

  prefix                = "${local.prefix}-event-authorizer"
  log_retention_in_days = var.log_retention_in_days

  source_dir    = var.event_authorizer.source_dir
  source_bucket = var.event_authorizer.source_bucket
  timeout       = var.event_authorizer.timeout
  memory_size   = var.event_authorizer.memory_size
  runtime       = var.event_authorizer.runtime
  handler       = var.event_authorizer.handler
  environment = merge(var.event_authorizer.environment == null ? {} : var.event_authorizer.environment, {
    FUN_EVENTS_SNS_OUTPUT_TOPIC = aws_sns_topic.connection_events_authorized[0].id
  })

  secrets = null
}

module "lambda_subscription_cleanup" {
  source = "../lambda"

  prefix                = "${local.prefix}-subscription-cleanup"
  log_retention_in_days = var.log_retention_in_days

  source_dir  = "${path.module}/../src/subscription_cleanup/build/"
  timeout     = 60
  memory_size = 256
  runtime     = "nodejs14.x"
  handler     = "index.handler"

  environment = {
    DYNAMO_SUBSCRIPTIONS_TABLE = aws_dynamodb_table.websocket_subscriptions.id
    SNS_INPUT_TOPIC            = aws_sns_topic.connection_deletion.id
  }

  secrets = null
}

// IAM

resource "aws_iam_role_policy_attachment" "lambda_event_expander" {
  role       = module.lambda_event_expander.role.name
  policy_arn = aws_iam_policy.lambda_event_expander.arn
}

resource "aws_iam_role_policy_attachment" "lambda_event_sender" {
  role       = module.lambda_event_sender.role.name
  policy_arn = aws_iam_policy.lambda_event_sender.arn
}

resource "aws_iam_role_policy_attachment" "lambda_event_authorizer" {
  count      = var.event_authorizer == null ? 0 : 1
  role       = module.lambda_event_authorizer[0].role.name
  policy_arn = aws_iam_policy.lambda_event_authorizer[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_subscription_cleanup" {
  role       = module.lambda_subscription_cleanup.role.name
  policy_arn = aws_iam_policy.lambda_subscription_cleanup.arn
}

resource "aws_iam_policy" "lambda_event_sender" {
  name = "${local.prefix}-event-sender"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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

resource "aws_iam_policy" "lambda_event_expander" {
  name = "${local.prefix}-event-expander"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:publish",
        ]
        Effect = "Allow"
        Resource = [
          aws_sns_topic.connection_events.arn,
          aws_sns_topic.subscription_events.arn,
        ]
      },
      {
        Action = [
          "dynamodb:Query",
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.websocket_subscriptions.arn,
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_event_authorizer" {
  count = var.event_authorizer == null ? 0 : 1
  name  = "${local.prefix}-event-authorizer"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:publish",
        ]
        Effect = "Allow"
        Resource = [
          aws_sns_topic.connection_events_authorized[0].arn
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_subscription_cleanup" {
  name = "${local.prefix}-subscription-cleanup"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:publish",
        ]
        Effect = "Allow"
        Resource = [
          aws_sns_topic.connection_deletion.arn,
        ]
      },
      {
        Action = [
          "dynamodb:BatchWriteItem",
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.websocket_subscriptions.arn,
        ]
      },
      {
        Action = [
          "dynamodb:Query",
        ]
        Effect = "Allow"
        Resource = [
          "${aws_dynamodb_table.websocket_subscriptions.arn}/index/*",
        ]
      },
    ]
  })
}

// Allow SNS to invoke lambdas

resource "aws_lambda_permission" "lambda_event_expander" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_event_expander.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.subscription_events.arn
}

resource "aws_lambda_permission" "lambda_event_sender" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_event_sender.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.event_authorizer == null ? aws_sns_topic.connection_events.arn : aws_sns_topic.connection_events_authorized[0].arn
}

resource "aws_lambda_permission" "lambda_event_authorizer" {
  count         = var.event_authorizer == null ? 0 : 1
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_event_authorizer[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.connection_events.arn
}

resource "aws_lambda_permission" "lambda_subscription_cleanup" {
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_subscription_cleanup.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.connection_deletion.arn
}
