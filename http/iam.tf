resource "aws_iam_role" "httpapi" {
  name               = "${local.prefix}-api"
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
  role   = aws_iam_role.httpapi.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": ${jsonencode(concat(module.lambda_api[*].function.arn, module.lambda_rpc[*].function.arn, module.authorizer[*].function.arn))}
        }
    ]
}
EOF
}
