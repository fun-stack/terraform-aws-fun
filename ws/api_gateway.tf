resource "aws_apigatewayv2_api" "websocket" {
  name                       = local.prefix
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.__action"
}

resource "aws_apigatewayv2_route" "websocket_default" {
  count     = length(module.lambda_rpc) > 0 ? 1 : 0
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.websocket_default[0].id}"
}
resource "aws_apigatewayv2_integration" "websocket_default" {
  count            = length(module.lambda_rpc) > 0 ? 1 : 0
  api_id           = aws_apigatewayv2_api.websocket.id
  integration_type = "AWS_PROXY"
  credentials_arn  = aws_iam_role.websocket.arn
  integration_uri  = module.lambda_rpc[0].function.invoke_arn
  # content_handling_strategy = "CONVERT_TO_BINARY"
}
resource "aws_apigatewayv2_integration_response" "websocket_default" {
  count                    = length(module.lambda_rpc) > 0 ? 1 : 0
  api_id                   = aws_apigatewayv2_api.websocket.id
  integration_id           = aws_apigatewayv2_integration.websocket_default[0].id
  integration_response_key = "/200/"
}
resource "aws_apigatewayv2_route_response" "websocket_default" {
  count              = length(module.lambda_rpc) > 0 ? 1 : 0
  api_id             = aws_apigatewayv2_api.websocket.id
  route_id           = aws_apigatewayv2_route.websocket_default[0].id
  route_response_key = "$default"
}

resource "aws_apigatewayv2_route" "websocket_connect" {
  api_id             = aws_apigatewayv2_api.websocket.id
  route_key          = "$connect"
  authorization_type = length(aws_apigatewayv2_authorizer.websocket) > 0 ? "CUSTOM" : null
  authorizer_id      = length(aws_apigatewayv2_authorizer.websocket) > 0 ? aws_apigatewayv2_authorizer.websocket[0].id : null
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
  integration_uri    = "arn:aws:apigateway:${data.aws_region.current.name}:sns:action/Publish"
  credentials_arn    = aws_iam_role.websocket.arn

  request_parameters = {
    "integration.request.querystring.TopicArn" = "'${aws_sns_topic.connection_deletion.id}'"
    "integration.request.querystring.Message"  = "context.connectionId"
  }
}

resource "aws_apigatewayv2_route" "websocket_subscribe" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "subscribe"

  target = "integrations/${aws_apigatewayv2_integration.websocket_subscribe.id}"
}

resource "aws_apigatewayv2_integration" "websocket_subscribe" {
  api_id             = aws_apigatewayv2_api.websocket.id
  integration_type   = "AWS"
  integration_method = "POST"
  integration_uri    = "arn:aws:apigateway:${data.aws_region.current.name}:dynamodb:action/PutItem"
  credentials_arn    = aws_iam_role.websocket.arn

  # ttl after 9000 secs = 2.5 hours, because of max connection duration of 2 hours on api gateway: https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html
  # To cleanup if disconnect is not called - because AWS only promises best-effort for disconnect.
  request_templates = {
    "application/json" = <<EOF
{
    "Item": {
      "subscription_key": {
        "S": "$input.path('$.subscription_key')"
      },
      "connection_id": {
        "S": "$context.connectionId"
      },
      #if("$context.authorizer.sub" != "")
      "user_id": {
        "S": "$context.authorizer.sub"
      },
      #end
      #set($delete_connection_at = ($context.requestTimeEpoch / 1000) + 9000)
      "ttl": {
        "N": "$delete_connection_at"
      }
    },
    "TableName": "${aws_dynamodb_table.websocket_subscriptions.name}"
}
EOF
  }
}

resource "aws_apigatewayv2_route" "websocket_unsubscribe" {
  api_id    = aws_apigatewayv2_api.websocket.id
  route_key = "unsubscribe"

  target = "integrations/${aws_apigatewayv2_integration.websocket_unsubscribe.id}"
}

resource "aws_apigatewayv2_integration" "websocket_unsubscribe" {
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
      },
      "subscription_key": {
        "S": "$input.json('$.subscription_key')"
      }
    },
    "TableName": "${aws_dynamodb_table.websocket_subscriptions.name}"
}
EOF
  }
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
    # TODO configure?
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

  depends_on = [
    module.dns[0]
  ]
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
  authorizer_uri             = module.authorizer[0].function.invoke_arn
  authorizer_credentials_arn = aws_iam_role.websocket.arn
  name                       = "authorize-websocket"
}
