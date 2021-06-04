data "archive_file" "http" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = local.http_zip_file
}

resource "aws_cloudwatch_log_group" "lambda_http" {
  name              = "/aws/lambda/${var.prefix}-http"
  retention_in_days = 3
}

resource "aws_lambda_function" "http" {
  function_name = "${var.prefix}-http"
  role          = aws_iam_role.lambda_http.arn

  timeout     = var.timeout
  memory_size = var.memory_size
  publish     = true

  runtime          = var.runtime
  handler          = var.handler
  filename         = local.http_zip_file
  source_code_hash = data.archive_file.http.output_base64sha256


  dynamic "environment" {
    for_each = var.environment == null || length(keys(var.environment)) == 0 ? [] : ["0"]
    content {
      variables = var.environment
    }
  }
}

resource "aws_iam_role" "lambda_http" {
  name               = "${var.prefix}-lambda-http"
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
