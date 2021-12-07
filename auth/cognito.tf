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
  identifier   = "${local.prefix}-api"
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
  logout_urls   = var.redirect_urls
  callback_urls = var.redirect_urls
}

resource "random_pet" "domain_name" {
  count = var.domain == null ? 1 : 0
  separator = "-"
  length = "3"
}

resource "aws_cognito_user_pool_domain" "user" {
  domain          = var.domain == null ? random_pet.domain_name[0].id : var.domain
  user_pool_id    = aws_cognito_user_pool.user.id
  certificate_arn = var.domain == null ? null : module.dns[0].certificate_arn
}

resource "aws_route53_record" "cognito" {
  count   = var.domain == null ? 0 : 1
  name    = aws_cognito_user_pool_domain.user.domain
  type    = "A"
  zone_id = var.hosted_zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.user.cloudfront_distribution_arn
    zone_id                = "Z2FDTNDATAQYW2" # This zone_id is fixed
  }
}
