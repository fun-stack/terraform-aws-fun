resource "aws_cognito_user_pool_client" "website_client" {
  name         = "${local.prefix}-website-client"
  user_pool_id = var.user_pool_id

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = [
    "code",
  ]
  allowed_oauth_scopes = concat(
    var.api_scopes,
    [
      "aws.cognito.signin.user.admin",
      "email",
      "openid",
      # "phone",
      # "profile",
    ]
  )
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
  ]
  supported_identity_providers = [
    "COGNITO",
  ]
  logout_urls   = [for url in var.redirect_urls : "${url}?logout"]
  callback_urls = var.redirect_urls
}

resource "aws_cognito_user_pool_ui_customization" "hosted_ui" {
  count     = var.css_content != null || var.image_base64_content != null ? 1 : 0
  client_id = aws_cognito_user_pool_client.website_client.id

  css        = var.css_content
  image_file = var.image_base64_content

  user_pool_id = var.user_pool_id
}
