module "authorizer" {
  count = var.auth_module == null ? 0 : 1

  source = "../authorizer/"

  prefix                = local.prefix
  cognito_user_pool_id  = var.auth_module.user_pool.id
  cognito_api_scopes    = join(" ", var.auth_module.api_scopes)
  identity_source       = "HEADER"
  allow_unauthenticated = var.allow_unauthenticated
}
