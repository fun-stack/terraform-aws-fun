module "lambda_rpc" {
  count  = var.rpc == null ? 0 : 1
  source = "../lambda"

  prefix                = "${local.prefix}-rpc"
  log_retention_in_days = var.log_retention_in_days

  source_bucket = var.rpc.source_bucket
  source_dir    = var.rpc.source_dir
  timeout       = var.rpc.timeout
  memory_size   = var.rpc.memory_size
  runtime       = var.rpc.runtime
  handler       = var.rpc.handler

  environment = merge(var.rpc.environment == null ? {} : var.rpc.environment, {
    FUN_EVENTS_SNS_OUTPUT_TOPIC = aws_sns_topic.subscription_events.id
  })

  vpc_config = var.rpc.vpc_config
}

resource "aws_iam_role_policy_attachment" "lambda_rpc_events" {
  count      = length(module.lambda_rpc) > 0 ? 1 : 0
  role       = module.lambda_rpc[0].role.name
  policy_arn = aws_iam_policy.subscription_events.arn
}
