data "archive_file" "http" {
  count       = var.source_bucket == null ? 1 : 0
  type        = "zip"
  source_dir  = var.source_dir
  output_path = local.http_zip_file
}

resource "aws_cloudwatch_log_group" "lambda_http" {
  name              = "/aws/lambda/${local.prefix}-http"
  retention_in_days = 3
}

resource "aws_lambda_function" "http" {
  function_name = "${local.prefix}-http"
  role          = aws_iam_role.lambda_http.arn

  timeout     = var.timeout
  memory_size = var.memory_size
  publish     = true

  runtime          = var.runtime
  handler          = var.handler
  s3_bucket        = var.source_bucket
  s3_key           = var.source_bucket == null ? null : var.source_dir
  filename         = var.source_bucket == null ? local.http_zip_file : null
  source_code_hash = var.source_bucket == null ? data.archive_file.http[0].output_base64sha256 : null


  dynamic "environment" {
    for_each = var.environment == null || length(keys(var.environment)) == 0 ? [] : ["0"]
    content {
      variables = var.environment
    }
  }
}

resource "aws_iam_role" "lambda_http" {
  name               = "${local.prefix}-lambda-http"
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

resource "aws_iam_role_policy_attachment" "lambda_http" {
  role       = aws_iam_role.lambda_http.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
