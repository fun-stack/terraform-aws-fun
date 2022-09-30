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

  dynamic "lambda_config" {
    for_each = length(module.lambda_post_authentication) > 0 || length(module.lambda_post_confirmation) > 0 || length(module.lambda_pre_authentication) > 0 || length(module.lambda_pre_sign_up) > 0 ? [0] : []
    content {
      post_authentication = length(module.lambda_post_authentication) > 0 ? module.lambda_post_authentication.function.arn : null
      post_confirmation   = length(module.lambda_post_confirmation) > 0 ? module.lambda_post_confirmation.function.arn : null
      pre_authentication  = length(module.lambda_pre_authentication) > 0 ? module.lambda_pre_authentication.function.arn : null
      pre_sign_up         = length(module.lambda_pre_sign_up) > 0 ? module.lambda_pre_sign_up.function.arn : null
    }
  }
}
resource "aws_cognito_resource_server" "user" {
  name         = "user"
  identifier   = "user"
  user_pool_id = aws_cognito_user_pool.user.id

  scope {
    scope_name        = "api"
    scope_description = "Get access to all API Gateway endpoints for http and ws."
  }
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

  depends_on = [
    module.dns[0]
  ]
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
