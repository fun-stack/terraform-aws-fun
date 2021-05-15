data "archive_file" "api" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = local.api_zip_file
}

resource "aws_cloudwatch_log_group" "lambda_api" {
  name              = "/aws/lambda/${var.prefix}-api"
  retention_in_days = 3
}

resource "aws_lambda_function" "api" {
  function_name = "${var.prefix}-api"
  role          = aws_iam_role.lambda_api.arn

  timeout     = var.timeout
  memory_size = var.memory_size
  publish     = true

  runtime          = var.runtime
  handler          = var.handler
  filename         = local.api_zip_file
  source_code_hash = data.archive_file.api.output_base64sha256

  # environment = {}
}

resource "aws_iam_role" "lambda_api" {
  name               = "${var.prefix}-lambda-api"
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

resource "aws_iam_role_policy_attachment" "lambda_api" {
  role       = aws_iam_role.lambda_api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
