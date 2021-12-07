resource "aws_apigatewayv2_api" "websocket" {
  name                       = "${local.prefix}-websocket"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_route" "websocket_default" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.websocket_default.id}"
}
resource "aws_apigatewayv2_integration" "websocket_default" {
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "AWS_PROXY"
  credentials_arn  = aws_iam_role.websocket.arn
  integration_uri  = aws_lambda_function.api.invoke_arn
  # content_handling_strategy = "CONVERT_TO_BINARY"
}
resource "aws_apigatewayv2_integration_response" "websocket_default" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.websocket_default.id
  integration_response_key = "/200/"
}
resource "aws_apigatewayv2_route_response" "websocket_default" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.websocket_default.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "websocket_commands" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "command"

  target = "integrations/${aws_apigatewayv2_integration.websocket_commands.id}"
}
resource "aws_apigatewayv2_integration" "websocket_commands" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS"
  integration_method = "POST"
  integration_uri    = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/PutItem"
  credentials_arn    = aws_iam_role.websocket.arn

  request_templates = {
    "application/json" = <<EOF
{
    "Item": {
      "sequence_number": {
        "S": "$context.requestTimeEpoch $context.connectionId $context.requestId"
      },
      "user_id": {
        #if("$context.authorizer.sub" == "")
        "S": "anon"
        #else
        "S": "$context.authorizer.sub"
        #end
      },
      "payload": {
        "S": "$input.path('$')"
      }
    },
    "TableName": "${aws_dynamodb_table.websocket_commands.name}"
}
EOF
  }
}
resource "aws_apigatewayv2_integration_response" "websocket_commands" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.websocket_commands.id
  integration_response_key = "/200/"
}
resource "aws_apigatewayv2_route_response" "websocket_commands" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.websocket_commands.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "websocket_ping" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "ping"

  target = "integrations/${aws_apigatewayv2_integration.websocket_ping.id}"
}
resource "aws_apigatewayv2_integration" "websocket_ping" {
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
    "statusCode": 200,
    "message": "pong"
}
EOF
  }
}
resource "aws_apigatewayv2_integration_response" "websocket_ping" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.websocket_ping.id
  integration_response_key = "/200/"
}
resource "aws_apigatewayv2_route_response" "websocket_ping" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.websocket_ping.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "websocket_connect" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_key          = "$connect"
  authorization_type = length(aws_apigatewayv2_authorizer.websocket) > 0 ? "CUSTOM" : null
  authorizer_id      = length(aws_apigatewayv2_authorizer.websocket) > 0 ? aws_apigatewayv2_authorizer.websocket[0].id : null

  target = "integrations/${aws_apigatewayv2_integration.websocket_connect.id}"
}
resource "aws_apigatewayv2_integration" "websocket_connect" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS"
  integration_method = "POST"
  integration_uri    = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/PutItem"
  credentials_arn    = aws_iam_role.websocket.arn

  request_templates = {
    "application/json" = <<EOF
{
    "Item": {
      "connection_id": {
        "S": "$context.connectionId"
      },
      "user_id": {
        #if("$context.authorizer.sub" == "")
        "S": "anon"
        #else
        "S": "$context.authorizer.sub"
        #end
      }
    },
    "TableName": "${aws_dynamodb_table.websocket_connections.name}"
}
EOF
  }
}
resource "aws_apigatewayv2_integration_response" "websocket_connect" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.websocket_connect.id
  integration_response_key = "/200/"
}
resource "aws_apigatewayv2_route_response" "websocket_connect" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.websocket_connect.id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "websocket_disconnect" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "$disconnect"

  target = "integrations/${aws_apigatewayv2_integration.websocket_disconnect.id}"
}
resource "aws_apigatewayv2_integration" "websocket_disconnect" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS"
  integration_method = "POST"
  integration_uri    = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/DeleteItem"
  credentials_arn    = aws_iam_role.websocket.arn

  request_templates = {
    "application/json" = <<EOF
{
    "Key": {
      "connection_id": {
        "S": "$context.connectionId"
      }
    },
    "TableName": "${aws_dynamodb_table.websocket_connections.name}"
}
EOF
  }
}
resource "aws_apigatewayv2_integration_response" "websocket_disconnect" {
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.websocket_disconnect.id
  integration_response_key = "/200/"
}
resource "aws_apigatewayv2_route_response" "websocket_disconnect" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.websocket_disconnect.id
  route_response_key = "$default"
}

resource "aws_iam_role" "websocket" {
  name               = "${local.prefix}-websocket-api"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "websocket" {
  role = aws_iam_role.websocket.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": [
              "${aws_dynamodb_table.websocket_connections.arn}",
              "${aws_dynamodb_table.websocket_commands.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": ${jsonencode(concat(
  [aws_lambda_function.api.arn],
  var.auth_module == null ? [] : [
    var.auth_module.authorizer_lambda.arn,
    var.auth_module.authorizer_lambda.invoke_arn
  ]
))}
        }
    ]
}
EOF
}

resource "aws_apigatewayv2_api_mapping" "websocket" {
  count       = var.domain == null ? 0 : 1
  api_id      = aws_apigatewayv2_api.websocket.id
  domain_name = aws_apigatewayv2_domain_name.websocket[0].id
  stage       = aws_apigatewayv2_stage.websocket.id
}

resource "aws_apigatewayv2_stage" "websocket" {
  api_id      = aws_apigatewayv2_api.websocket.id
  name        = "latest"
  auto_deploy = true

  default_route_settings {
    # data_trace_enabled       = true
    # detailed_metrics_enabled = true
    # logging_level            = "INFO"
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

resource "aws_apigatewayv2_domain_name" "websocket" {
  count       = var.domain == null ? 0 : 1
  domain_name = var.domain

  domain_name_configuration {
    certificate_arn = module.dns[0].certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}
resource "aws_route53_record" "websocket" {
  count   = var.domain == null ? 0 : 1
  name    = aws_apigatewayv2_domain_name.websocket[0].domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.websocket[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.websocket[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_authorizer" "websocket" {
  count = var.auth_module == null ? 0 : 1

  api_id                     = aws_apigatewayv2_api.websocket.id
  authorizer_type            = "REQUEST"
  authorizer_uri             = var.auth_module.authorizer_lambda.invoke_arn
  authorizer_credentials_arn = aws_iam_role.websocket.arn
  identity_sources           = ["route.request.querystring.token"]
  name                       = "authorize-websocket"
}
