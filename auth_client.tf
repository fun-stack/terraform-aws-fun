module "auth_client" {
  count  = var.auth == null ? 0 : 1
  source = "./auth_client"

  prefix = local.prefix

  css_content          = var.auth.css_content
  image_base64_content = var.auth.image_base64_content

  user_pool_id = module.auth[0].user_pool.id
  api_scopes   = module.auth[0].api_scopes

  redirect_urls = local.auth_redirect_urls

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
