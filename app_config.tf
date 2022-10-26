locals {
  app_config = {
    stage  = var.stage,
    region = data.aws_region.current.name
  }

  app_config_website = local.website == null ? {} : {
    website = {
      url                     = local.url_website
      environment             = local.website.environment == null ? {} : local.website.environment
      authTokenInLocalStorage = local.website.auth_token_in_local_storage
    }
  }

  app_config_ws = local.ws == null ? {} : {
    ws = {
      url                  = local.url_ws
      allowUnauthenticated = local.ws.allow_unauthenticated
    }
  }

  app_config_http = local.http == null ? {} : {
    http = {
      url                  = local.url_http
      allowUnauthenticated = local.http.allow_unauthenticated
    }
  }

  app_config_auth = local.auth == null ? {} : {
    auth = {
      url       = local.url_auth
      idpUrl    = local.url_auth_idp
      clientId  = module.auth_client[0].user_pool_client.id
      apiScopes = join(" ", module.auth[0].api_scopes)
    }
  }

  app_config_json = jsonencode(merge(local.app_config, local.app_config_website, local.app_config_ws, local.app_config_http, local.app_config_auth))

  app_config_js = <<EOF
window.AppConfig = ${local.app_config_json};
EOF
}
