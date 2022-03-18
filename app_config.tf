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
      url      = local.url_auth
      clientId = module.auth[0].user_pool_client.id
    }
  }

  app_config_js = <<EOF
window.AppConfig = ${jsonencode(merge(local.app_config, local.app_config_website, local.app_config_ws, local.app_config_http, local.app_config_auth))};
EOF
}
