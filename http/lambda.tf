module "lambda_api" {
  count = var.api == null ? 0 : 1

  source  = "cornerman/lambda/aws"
  version = "0.1.5"

  name                  = "${local.prefix}-api"
  log_retention_in_days = var.log_retention_in_days

  source_bucket = var.api.source_bucket
  source_dir    = var.api.source_dir
  timeout       = var.api.timeout
  memory_size   = var.api.memory_size
  runtime       = var.api.runtime
  handler       = var.api.handler

  architecture  = var.api.architecture

  environment = var.api.environment

  vpc_config = var.api.vpc_config

  layers = var.api.layers
}

module "lambda_rpc" {
  count = var.rpc == null ? 0 : 1

  source  = "cornerman/lambda/aws"
  version = "0.1.5"

  name                  = "${local.prefix}-rpc"
  log_retention_in_days = var.log_retention_in_days

  source_bucket = var.rpc.source_bucket
  source_dir    = var.rpc.source_dir
  timeout       = var.rpc.timeout
  memory_size   = var.rpc.memory_size
  runtime       = var.rpc.runtime
  handler       = var.rpc.handler

  architecture  = var.rpc.architecture

  environment = var.rpc.environment

  vpc_config = var.rpc.vpc_config

  layers = var.rpc.layers
}
