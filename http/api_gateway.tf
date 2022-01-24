resource "aws_apigatewayv2_api" "httpapi" {
  name          = "${local.prefix}-httpapi"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = var.allow_origins
    allow_methods = ["GET", "POST", "PUT", "DELETE"]
    allow_headers = ["authorization"]
  }
}

resource "aws_apigatewayv2_route" "httpapi_default" {
  for_each  = toset(["GET", "POST", "PUT", "DELETE"])
  api_id    = aws_apigatewayv2_api.httpapi.id
  route_key = "${each.value} /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.httpapi_default.id}"
}
resource "aws_apigatewayv2_integration" "httpapi_default" {
  api_id                 = aws_apigatewayv2_api.httpapi.id
  integration_type       = "AWS_PROXY"
  credentials_arn        = aws_iam_role.httpapi.arn
  integration_uri        = aws_lambda_function.http.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_iam_role" "httpapi" {
  name               = "${local.prefix}-httpapi-api"
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

resource "aws_iam_role_policy" "httpapi" {
  role = aws_iam_role.httpapi.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": ${jsonencode(concat(
  [
    aws_lambda_function.http.arn,
    aws_lambda_function.http.invoke_arn
  ],
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

# resource "aws_apigatewayv2_authorizer" "httpapi" {
#   count = var.auth_module == null ? 0 : 1

#   api_id                     = aws_apigatewayv2_api.httpapi.id
#   authorizer_type            = "REQUEST"
#   authorizer_uri             = var.auth_module.authorizer_lambda.invoke_arn
#   authorizer_credentials_arn = aws_iam_role.httpapi.arn
#   name                       = "authorize-httpapi"
# }
