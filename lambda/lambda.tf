data "archive_file" "lambda" {
  count       = var.source_bucket == null ? 1 : 0
  type        = "zip"
  source_dir  = var.source_dir
  output_path = local.lambda_zip_file
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.prefix}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_lambda_function" "lambda" {
  function_name = local.prefix
  role          = aws_iam_role.lambda.arn

  timeout     = var.timeout
  memory_size = var.memory_size
  publish     = true

  runtime = var.runtime
  handler = var.handler

  s3_bucket        = var.source_bucket
  s3_key           = var.source_bucket == null ? null : var.source_dir
  filename         = var.source_bucket == null ? local.lambda_zip_file : null
  source_code_hash = var.source_bucket == null ? data.archive_file.lambda[0].output_base64sha256 : null //TODO with source_bucket

  dynamic "environment" {
    for_each = var.environment == null || length(keys(var.environment)) == 0 ? [] : ["0"]
    content {
      variables = var.environment
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : ["0"]
    content {
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = local.prefix
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

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = var.vpc_config == null ? "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" : "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
