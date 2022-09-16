module "lambda" {
  source  = "cornerman/lambda/aws"
  version = "0.1.1"

  prefix                = local.prefix
  log_retention_in_days = var.log_retention_in_days

  source_dir  = "${path.module}/../src/authorizer/build/"
  timeout     = 30
  memory_size = 128
  runtime     = "nodejs14.x"
  handler     = "index.handler"

  environment = {
    COGNITO_POOL_ID       = var.cognito_user_pool_id
    COGNITO_API_SCOPES    = var.cognito_api_scopes
    ALLOW_UNAUTHENTICATED = var.allow_unauthenticated
    IDENTITY_SOURCE       = var.identity_source
  }

  vpc_config = null
}
