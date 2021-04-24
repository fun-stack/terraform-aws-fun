resource "aws_cognito_user_pool" "user" {
  name = "${local.prefix}-user"

  #TODO
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  #TODO
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  #TODO
  password_policy {
    temporary_password_validity_days = 7
    minimum_length                   = 6
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
  }
}
resource "aws_cognito_resource_server" "user" {
  name         = "${local.prefix}-user-ws"
  identifier   = local.domain_ws
  user_pool_id = aws_cognito_user_pool.user.id

  scope {
    scope_name        = "api"
    scope_description = "Get access to all API Gateway WS endpoints."
  }
}
resource "aws_cognito_user_pool_client" "website_client" {
  name         = "${local.prefix}-website-client"
  user_pool_id = aws_cognito_user_pool.user.id

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = [
    "code",
    "implicit",
  ]
  allowed_oauth_scopes = concat(
    aws_cognito_resource_server.user.scope_identifiers,
    [
      "aws.cognito.signin.user.admin",
      "email",
      "openid",
      "phone",
      "profile",
    ]
  )
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
  ]
  supported_identity_providers = [
    "COGNITO",
  ]
  logout_urls   = local.redirect_urls
  callback_urls = local.redirect_urls
}

resource "aws_cognito_identity_pool" "user" {
  identity_pool_name = "${local.prefix}-user"

  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.website_client.id
    provider_name           = aws_cognito_user_pool.user.endpoint
    server_side_token_check = false
  }
}

resource "aws_cognito_user_pool_domain" "user" {
  domain          = local.domain_auth
  user_pool_id    = aws_cognito_user_pool.user.id
  certificate_arn = aws_acm_certificate.auth.arn

  depends_on = [aws_route53_record.website]
}

resource "aws_route53_record" "cognito" {
  name    = aws_cognito_user_pool_domain.user.domain
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.user.cloudfront_distribution_arn
    zone_id                = "Z2FDTNDATAQYW2" # This zone_id is fixed
  }
}
