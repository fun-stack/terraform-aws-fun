module "http_stripe_api" {
  source = "../http"

  prefix         = var.prefix
  domain         = var.domain
  hosted_zone_id = var.hosted_zone_id
  auth_module    = var.auth_module

  source_dir  = "${path.module}/stripe_api"
  timeout     = 30
  memory_size = 128
  runtime     = "nodejs14.x"
  handler     = "index.handler"

  environment = {
    STRIPE_API_TOKEN = var.stripe_api_token_private
  }

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}

