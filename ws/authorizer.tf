module "authorizer" {
  count = var.auth_module == null ? 0 : 1

  source = "../authorizer/"

  prefix                = local.prefix
  log_retention_in_days = var.log_retention_in_days
  cognito_user_pool_id  = var.auth_module.user_pool.id
  cognito_api_scopes    = join(" ", var.auth_module.api_scopes)
  identity_source       = "QUERYSTRING"
  allow_unauthenticated = var.allow_unauthenticated
}
