variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "stage" {
  description = "The stage name, that is dev, staging, prod, etc."
  type        = string
}

variable "domain" {
  description = "Deploy under a custom domain. for this to work, you will need a hosted zone for this domain in your aws account."
  type        = string
  default     = null
}

variable "deploy_to_root_domain" {
  description = "Deploy to the root domain. If true, deploys app to the root domain. If false, deploys app to <stage>.env.<domain>."
  type        = bool
  default     = true
}

variable "catch_all_forward_to" {
  description = "Email address to which all @domain email should be forwarded."
  type        = string
  default     = null
}

variable "dev_setup" {
  type = object({
    enabled           = optional(bool)
    local_website_url = optional(string)
  })
  default = {}
}

variable "auth" {
  description = "auth module with cognito"
  type = object({
  })
  default = null
}

variable "website" {
  description = "website module with cloudfront and s3"
  type = object({
    source_dir          = string
    source_bucket       = optional(string)
    index_file          = optional(string)
    error_file          = optional(string)
    cache_files_regex   = optional(string)
    cache_files_max_age = optional(number)
    environment         = optional(map(string))
    rewrites            = optional(map(string))
  })
}

variable "ws" {
  description = "ws module with api gateway websockets"
  type = object({
    source_dir            = string
    source_bucket         = optional(string)
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
  description = "http module with api gateway http"
  type = object({
    source_dir     = string
    source_bucket  = optional(string)
    handler        = string
    runtime        = string
    timeout        = number
    memory_size    = number
    cors_protected = optional(bool)
    environment    = optional(map(string))
  })
  default = null
}

variable "budget" {
  description = "create a budget with email notification for this deployment"
  type = object({
    limit_monthly_dollar = string
    notify_email         = string
  })
  default = null
}

locals {
  module_name = replace(basename(abspath(path.module)), "_", "-")

  # dev_setup = defaults(var.dev_setup == null ? {} : var.dev_setup, {
  #   enabled = true
  # })
  dev_setup = defaults(var.dev_setup, {
    enabled = true
  })

  website = var.website == null ? null : defaults(var.website, {
    index_file          = "index.html"
    error_file          = "error.html"
    cache_files_regex   = ""
    cache_files_max_age = 31536000
  })

  ws = var.ws == null ? null : defaults(var.ws, {
    allow_unauthenticated = false
  })

  http = var.http == null ? null : defaults(var.http, {
    cors_protected        = true
  })

  auth = var.auth == null ? null : defaults(var.auth, {
  })

  prefix = "fun-${local.module_name}-${var.stage}"

  domain         = var.deploy_to_root_domain || var.domain == null ? var.domain : "${var.stage}.env.${var.domain}"
  domain_website = local.domain
  domain_auth    = local.domain == null ? null : "auth.${local.domain}"
  domain_ws      = local.domain == null ? null : "ws.${local.domain}"
  domain_http    = local.domain == null ? null : "api.${local.domain}"

  url_website = coalesce(local.domain == null ? null : "https://${local.domain}", "https://${aws_cloudfront_distribution.website.domain_name}")
  url_auth    = length(module.auth) > 0 ? coalesce(local.domain_auth == null ? null : "https://${local.domain_auth}", module.auth[0].url) : null
  url_ws      = length(module.ws) > 0 ? coalesce(local.domain_ws == null ? null : "wss://${local.domain_ws}", module.ws[0].url) : null
  url_http    = length(module.http) > 0 ? coalesce(local.domain_http == null ? null : "https://${local.domain_http}", module.http[0].url) : null

  redirect_urls = concat(
    [local.url_website],
    local.dev_setup.enabled && local.dev_setup.local_website_url != null ? [local.dev_setup.local_website_url] : []
  )

  # wget --output-document mime.json https://raw.githubusercontent.com/micnic/mime.json/master/index.json
  content_type_map = jsondecode(file("${path.module}/mime.json"))

  app_config = {
    stage  = var.stage,
    region = data.aws_region.current.name,
    website = {
      url = local.url_website
    }
    environment = local.website.environment == null ? {} : local.website.environment
  }

  app_config_ws = local.ws == null ? {} : {
    ws = {
      url                  = local.url_ws
      allowUnauthenticated = local.ws.allow_unauthenticated
    }
  }

  app_config_http = local.http == null ? {} : {
    http = {
      url = local.url_http
    }
  }

  app_config_auth = local.auth == null ? {} : {
    auth = {
      url      = local.url_auth
      clientId = module.auth[0].user_pool_client.id
    }
  }

  app_config_js = <<EOF
window.AppConfig = ${jsonencode(merge(local.app_config, local.app_config_ws, local.app_config_http, local.app_config_auth))};
EOF

  app_config_js_filename = "${path.module}/serve/app_config.js"
}
