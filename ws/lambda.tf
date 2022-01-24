data "archive_file" "ws" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = local.ws_zip_file
}

resource "aws_cloudwatch_log_group" "lambda_ws" {
  name              = "/aws/lambda/${local.prefix}-ws"
  retention_in_days = 3
}

resource "aws_lambda_function" "ws" {
  function_name = "${local.prefix}-ws"
  role          = aws_iam_role.lambda_ws.arn

  timeout     = var.timeout
  memory_size = var.memory_size
  publish     = true

  runtime          = var.runtime
  handler          = var.handler
  filename         = local.ws_zip_file
  source_code_hash = data.archive_file.ws.output_base64sha256

  environment {
    variables = merge(var.environment == null ? {} : var.environment, {
      FUN_WEBSOCKET_CONNECTIONS_DYNAMODB_TABLE = aws_dynamodb_table.websocket_connections.id
    })
  }
}

resource "aws_iam_role" "lambda_ws" {
  name               = "${local.prefix}-lambda-ws"
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

resource "aws_iam_role_policy_attachment" "lambda_ws" {
  role       = aws_iam_role.lambda_ws.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_ws_connections" {
  role       = aws_iam_role.lambda_ws.name
  policy_arn = aws_iam_policy.websocket_connections.arn
}
