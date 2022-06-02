module "lambda_post_authentication" {
  count  = var.post_authentication_trigger == null ? 0 : 1
  source = "../lambda"

  prefix                = "${local.prefix}-post-authentication-trigger"
  log_retention_in_days = var.log_retention_in_days

  source_bucket = var.post_authentication_trigger.source_bucket
  source_dir    = var.post_authentication_trigger.source_dir
  timeout       = var.post_authentication_trigger.timeout
  memory_size   = var.post_authentication_trigger.memory_size
  runtime       = var.post_authentication_trigger.runtime
  handler       = var.post_authentication_trigger.handler

  environment = var.post_authentication_trigger.environment
}

module "lambda_post_confirmation" {
  count  = var.post_confirmation_trigger == null ? 0 : 1
  source = "../lambda"

  prefix                = "${local.prefix}-post-confirmation-trigger"
  log_retention_in_days = var.log_retention_in_days

  source_bucket = var.post_confirmation_trigger.source_bucket
  source_dir    = var.post_confirmation_trigger.source_dir
  timeout       = var.post_confirmation_trigger.timeout
  memory_size   = var.post_confirmation_trigger.memory_size
  runtime       = var.post_confirmation_trigger.runtime
  handler       = var.post_confirmation_trigger.handler

  environment = var.post_confirmation_trigger.environment
}

module "lambda_pre_authentication" {
  count  = var.pre_authentication_trigger == null ? 0 : 1
  source = "../lambda"

  prefix                = "${local.prefix}-pre-authentication-trigger"
  log_retention_in_days = var.log_retention_in_days

  source_bucket = var.pre_authentication_trigger.source_bucket
  source_dir    = var.pre_authentication_trigger.source_dir
  timeout       = var.pre_authentication_trigger.timeout
  memory_size   = var.pre_authentication_trigger.memory_size
  runtime       = var.pre_authentication_trigger.runtime
  handler       = var.pre_authentication_trigger.handler

  environment = var.pre_authentication_trigger.environment
}

module "lambda_pre_sign_up" {
  count  = var.pre_sign_up_trigger == null ? 0 : 1
  source = "../lambda"

  prefix                = "${local.prefix}-pre-sign-up-trigger"
  log_retention_in_days = var.log_retention_in_days

  source_bucket = var.pre_sign_up_trigger.source_bucket
  source_dir    = var.pre_sign_up_trigger.source_dir
  timeout       = var.pre_sign_up_trigger.timeout
  memory_size   = var.pre_sign_up_trigger.memory_size
  runtime       = var.pre_sign_up_trigger.runtime
  handler       = var.pre_sign_up_trigger.handler

  environment = var.pre_sign_up_trigger.environment
}
