locals {
  app_config = {
    stage  = var.stage,
    region = data.aws_region.current.name
  }

  app_config_website = var.website == null ? {} : {
    website = {
      url                     = local.url_website
      environment             = var.website.environment
      authTokenInLocalStorage = var.website.auth_token_in_local_storage
    }
  }

  app_config_ws = var.ws == null ? {} : {
    ws = {
      url                  = local.url_ws
      allowUnauthenticated = var.ws.allow_unauthenticated
    }
  }

  app_config_http = var.http == null ? {} : {
    http = {
      url                  = local.url_http
      allowUnauthenticated = var.http.allow_unauthenticated
    }
  }

  app_config_auth = var.auth == null ? {} : {
    auth = {
      url       = local.url_auth
      idpUrl    = local.url_auth_idp
      clientId  = module.auth_client[0].user_pool_client.id
      apiScopes = join(" ", module.auth[0].api_scopes)
    }
  }

  app_config_json = jsonencode(merge(local.app_config, local.app_config_website, local.app_config_ws, local.app_config_http, local.app_config_auth))
}
