resource "aws_cognito_user_pool" "user" {
  name = "${local.prefix}-user"


  admin_create_user_config {
    allow_admin_create_user_only = var.admin_registration_only
  }

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

  lambda_config {
    post_authentication = length(module.lambda_post_authentication) > 0 ? module.lambda_post_authentication.function.arn : null
    post_confirmation   = length(module.lambda_post_confirmation) > 0 ? module.lambda_post_confirmation.function.arn : null
    pre_authentication  = length(module.lambda_pre_authentication) > 0 ? module.lambda_pre_authentication.function.arn : null
    pre_sign_up         = length(module.lambda_pre_sign_up) > 0 ? module.lambda_pre_sign_up.function.arn : null
  }
}
resource "aws_cognito_resource_server" "user" {
  name         = "${local.prefix}-user-api"
  identifier   = "${local.prefix}-user-api"
  user_pool_id = aws_cognito_user_pool.user.id

  scope {
    scope_name        = "api"
    scope_description = "Get access to all API Gateway endpoints for http and ws."
  }
}
resource "aws_cognito_user_pool_client" "website_client" {
  name         = "${local.prefix}-website-client"
  user_pool_id = aws_cognito_user_pool.user.id

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = [
    "code",
  ]
  allowed_oauth_scopes = concat(
    aws_cognito_resource_server.user.scope_identifiers,
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
  count     = var.css_file != null || var.image_file != null ? 1 : 0
  client_id = aws_cognito_user_pool_client.website_client.id

  css        = var.css_file == null ? null : file(var.css_file) //".label-customizable {font-weight: 400;}"
  image_file = var.image_file == null ? null : filebase64(var.image_file)

  user_pool_id = aws_cognito_user_pool_domain.user.user_pool_id
}

resource "random_pet" "domain_name" {
  count     = var.domain == null ? 1 : 0
  separator = "-"
  length    = "3"
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
