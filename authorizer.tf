data "archive_file" "authorizer" {
  type        = "zip"
  source_file = "${path.module}/authorizer/index.js"
  output_path = local.authorizer_zip_file
}

resource "aws_cloudwatch_log_group" "lambda_authorizer" {
  name              = "/aws/lambda/${local.prefix}-authorizer"
  retention_in_days = 3
}

resource "aws_lambda_function" "authorizer" {
  function_name = "${local.prefix}-authorizer"
  role          = aws_iam_role.lambda_authorizer.arn

  timeout     = 30
  memory_size = 128
  publish     = true

  runtime          = "nodejs14.x"
  handler          = "index.handler"
  filename         = local.authorizer_zip_file
  source_code_hash = data.archive_file.authorizer.output_base64sha256

  environment {
    variables = {
      COGNITO_POOL_ID       = aws_cognito_user_pool.user.id
      COGNITO_API_SCOPES    = join(" ", aws_cognito_resource_server.user.scope_identifiers)
      ALLOW_UNAUTHENTICATED = var.allow_unauthenticated
    }
  }
}

resource "aws_iam_role" "lambda_authorizer" {
  name               = "${local.prefix}-lambda-authorizer"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_authorizer" {
  role       = aws_iam_role.lambda_authorizer.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
