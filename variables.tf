variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "domain" {
  type = string
}

variable "catch_all_forward_to" {
  type    = string
  default = null
}

variable "prod_workspace" {
  type    = string
  default = "default"
}
variable "dev_workspaces" {
  type    = list(string)
  default = ["default"]
}

variable "dev_setup" {
  type = object({
    local_website_url = string
    local_http_host   = optional(string)
    local_ws_host     = optional(string)
  })
  default = null
}

variable "auth" {
  type = object({
  })
  default = null
}

variable "website" {
  type = object({
    source_dir          = string
    index_file          = optional(string)
    error_file          = optional(string)
    cache_files_regex   = optional(string)
    cache_files_max_age = optional(number)
    environment         = optional(map(string))
  })
}

variable "api" {
  type = object({
    source_dir            = string
    handler               = string
    runtime               = string
    timeout               = number
    memory_size           = number
    allow_unauthenticated = optional(bool)
    environment           = optional(map(string))
  })
  default = null
}

variable "http" {
  type = object({
    source_dir  = string
    handler     = string
    runtime     = string
    timeout     = number
    memory_size = number
    environment = optional(map(string))
  })
  default = null
}

variable "budget" {
  type = object({
    limit_monthly_dollar = string
    notify_email         = string
  })
  default = null
}

locals {
  module_name = replace(basename(abspath(path.module)), "_", "-")

  website = var.website == null ? null : defaults(var.website, {
    index_file          = "index.html"
    error_file          = "error.html"
    cache_files_regex   = ""
    cache_files_max_age = 31536000
  })

  api = var.api == null ? null : defaults(var.api, {
    allow_unauthenticated = false
  })

  http = var.http == null ? null : defaults(var.http, {
  })

  auth = var.auth == null ? null : defaults(var.auth, {
  })

  prefix = "fun-${local.module_name}-${terraform.workspace}"

  is_dev = var.dev_setup != null && contains(var.dev_workspaces, terraform.workspace)

  domain         = terraform.workspace == var.prod_workspace ? var.domain : "${terraform.workspace}.env.${var.domain}"
  domain_website = local.domain
  domain_auth    = "auth.${local.domain}"
  domain_ws      = "ws.${local.domain}"
  domain_http    = "api.${local.domain}"
  redirect_urls = concat(
    ["https://${local.domain_website}"],
    local.is_dev ? [var.dev_setup.local_website_url] : []
  )

  api_zip_file        = "${path.module}/api.zip"
  authorizer_zip_file = "${path.module}/authorizer.zip"

  content_type_map = {
    html = "text/html",
    js   = "application/javascript",
    css  = "text/css",
    svg  = "image/svg+xml",
    jpg  = "image/jpeg",
    ico  = "image/x-icon",
    png  = "image/png",
    gif  = "image/gif",
    pdf  = "application/pdf"
  }

  app_config = {
    stage  = terraform.workspace,
    region = data.aws_region.current.name,
    website = {
      domain = local.domain_website
    }
    environment = local.website.environment == null ? {} : local.website.environment
  }

  app_config_api = local.api == null ? {} : {
    api = {
      domain               = local.domain_ws
      allowUnauthenticated = local.api.allow_unauthenticated
    }
  }

  app_config_http = local.http == null ? {} : {
    http = {
      domain = local.domain_http
    }
  }

  app_config_dev_api = local.api == null ? {} : {
    api = {
      domain               = local.is_dev && var.dev_setup.local_ws_host != null ? var.dev_setup.local_ws_host : local.domain_ws
      allowUnauthenticated = local.api.allow_unauthenticated
    }
  }

  app_config_dev_http = local.http == null ? {} : {
    http = {
      domain = local.is_dev && var.dev_setup.local_http_host != null ? var.dev_setup.local_http_host : local.domain_http
    }
  }

  app_config_auth = local.auth == null ? {} : {
    auth = {
      domain          = local.domain_auth
      clientIdAuth    = module.auth[0].user_pool_client.id
      identityPoolId  = module.auth[0].identity_pool.id
      cognitoEndpoint = module.auth[0].user_pool.endpoint
    }
  }

  app_config_js = <<EOF
window.AppConfig = ${jsonencode(merge(local.app_config, local.app_config_api, local.app_config_http, local.app_config_auth))};
EOF

  app_config_dev_js = <<EOF
window.AppConfig = ${jsonencode(merge(local.app_config, local.app_config_dev_api, local.app_config_dev_http, local.app_config_auth))};
EOF
}
