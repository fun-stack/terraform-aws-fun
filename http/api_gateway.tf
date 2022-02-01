resource "aws_apigatewayv2_api" "httpapi" {
  name          = local.prefix
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = var.allow_origins
    allow_methods = ["GET", "POST", "PUT", "DELETE"]
    allow_headers = ["authorization"]
  }
}

resource "aws_apigatewayv2_route" "httpapi_default" {
  for_each  = var.api == null ? [] : toset(["GET", "POST", "PUT", "DELETE"])
  api_id    = aws_apigatewayv2_api.httpapi.id
  route_key = "${each.value} /{proxy+}"

  authorization_type = length(aws_apigatewayv2_authorizer.httpapi) > 0 ? "CUSTOM" : null
  authorizer_id      = length(aws_apigatewayv2_authorizer.httpapi) > 0 ? aws_apigatewayv2_authorizer.httpapi[0].id : null

  target = "integrations/${aws_apigatewayv2_integration.httpapi_default[0].id}"
}
resource "aws_apigatewayv2_integration" "httpapi_default" {
  count                  = var.api == null ? 0 : 1
  api_id                 = aws_apigatewayv2_api.httpapi.id
  integration_type       = "AWS_PROXY"
  credentials_arn        = aws_iam_role.httpapi.arn
  integration_uri        = module.lambda_api[0].function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "httpapi_underscore" {
  for_each  = var.api == null ? [] : toset(["POST"])
  api_id    = aws_apigatewayv2_api.httpapi.id
  route_key = "${each.value} /_/{proxy+}"

  authorization_type = length(aws_apigatewayv2_authorizer.httpapi) > 0 ? "CUSTOM" : null
  authorizer_id      = length(aws_apigatewayv2_authorizer.httpapi) > 0 ? aws_apigatewayv2_authorizer.httpapi[0].id : null

  target = "integrations/${aws_apigatewayv2_integration.httpapi_underscore[0].id}"
}
resource "aws_apigatewayv2_integration" "httpapi_underscore" {
  count                  = var.rpc == null ? 0 : 1
  api_id                 = aws_apigatewayv2_api.httpapi.id
  integration_type       = "AWS_PROXY"
  credentials_arn        = aws_iam_role.httpapi.arn
  integration_uri        = module.lambda_rpc[0].function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_api_mapping" "httpapi" {
  count       = var.domain == null ? 0 : 1
  api_id      = aws_apigatewayv2_api.httpapi.id
  domain_name = aws_apigatewayv2_domain_name.httpapi[0].id
  stage       = aws_apigatewayv2_stage.httpapi.id
}

resource "aws_apigatewayv2_stage" "httpapi" {
  api_id      = aws_apigatewayv2_api.httpapi.id
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

resource "aws_apigatewayv2_domain_name" "httpapi" {
  count       = var.domain == null ? 0 : 1
  domain_name = var.domain

  domain_name_configuration {
    certificate_arn = module.dns[0].certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}
resource "aws_route53_record" "httpapi" {
  count   = var.domain == null ? 0 : 1
  name    = aws_apigatewayv2_domain_name.httpapi[0].domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.httpapi[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.httpapi[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_authorizer" "httpapi" {
  count = var.auth_module == null ? 0 : 1

  api_id                            = aws_apigatewayv2_api.httpapi.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = module.authorizer[0].function.invoke_arn
  authorizer_credentials_arn        = aws_iam_role.httpapi.arn
  name                              = "authorize-http"
  authorizer_result_ttl_in_seconds  = 0 # we need to configure an identity source for caching. But we want the auth token to be optional - and that is not possible with identity source.
  authorizer_payload_format_version = "1.0"
}
