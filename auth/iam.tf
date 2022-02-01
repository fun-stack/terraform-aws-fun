resource "aws_iam_policy" "get_info" {
  name = "${local.prefix}-get-info"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cognito-idp:AdminGetUser"
        ]
        Effect = "Allow"
        Resource = [
          aws_cognito_user_pool.user.arn
        ]
      },
    ]
  })
}
