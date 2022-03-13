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
    for_each = (var.environment == null || length(keys(var.environment)) == 0) && (var.secrets == null || (length(keys(var.secrets.ssm_parameter == null ? {} : var.secrets.ssm_parameter)) == 0 && length(keys(var.secrets.ssm_parameter == null ? {} : var.secrets.ssm_parameter)) == 0)) ? [] : ["0"]
    content {
      variables = merge(
        var.environment == null ? {} : var.environment,
        var.secrets == null ? {} : merge(
          var.secrets.secretsmanager == null ? {} : { for k, v in var.secrets.secretsmanager : "FUN_SECRETS_SECRETSMANAGER_${k}" => v },
          var.secrets.ssm_parameter == null ? {} : { for k, v in var.secrets.ssm_parameter : "FUN_SECRETS_SSM_PARAMETER_${k}" => v }
        )
      )
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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "read_secrets" {
  count = var.secrets == null || (length(keys(var.secrets.ssm_parameter == null ? {} : var.secrets.ssm_parameter)) == 0 && length(keys(var.secrets.ssm_parameter == null ? {} : var.secrets.ssm_parameter)) == 0) ? 0 : 1
  name  = "${local.prefix}-read-secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "secretsmanager:GetSecretValue",
        ]
        Effect = "Allow"
        Resource = concat(
          var.secrets.secretsmanager == null ? {} : [for k, v in var.secrets.secretsmanager : "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${k}"],
          var.secrets.ssm_parameter == null ? {} : [for k, v in var.secrets.ssm_parameter : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${k}"]
        )
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "read_secrets" {
  count      = length(aws_iam_policy.read_secrets)
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.read_secrets[count.index].arn
}
