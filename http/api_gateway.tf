resource "aws_apigatewayv2_api" "httpapi" {
  name          = "${var.prefix}-httpapi"
  protocol_type = "HTTP"
  body          = local.swagger_yaml_patched
}

resource "local_file" "swagger_yaml" {
  filename = "${path.module}/swagger.yaml"
  content  = local.swagger_yaml_patched
}

resource "aws_iam_role" "httpapi" {
  name               = "${var.prefix}-httpapi-api"
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
  api_id      = aws_apigatewayv2_api.httpapi.id
  domain_name = aws_apigatewayv2_domain_name.httpapi.id
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
  domain_name = var.domain

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.http.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}
resource "aws_route53_record" "httpapi" {
  name    = aws_apigatewayv2_domain_name.httpapi.domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.httpapi.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.httpapi.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# resource "aws_apigatewayv2_authorizer" "httpapi" {
#   count = var.auth_module == null ? 0 : 1

#   api_id                     = aws_apigatewayv2_api.httpapi.id
#   authorizer_type            = "REQUEST"
#   authorizer_uri             = var.auth_module.authorizer_lambda.invoke_arn
#   authorizer_credentials_arn = aws_iam_role.httpapi.arn
#   identity_sources           = ["route.request.querystring.token"]
#   name                       = "authorize-httpapi"
# }
