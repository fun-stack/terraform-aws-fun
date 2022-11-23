variable "name_prefix" {
  description = "Prefix for naming resources in the deployment."
  type        = string
  default     = null
}

variable "stage" {
  description = "The stage name, that is dev, staging, prod, etc."
  type        = string
}

variable "domain" {
  description = "Deploy under a custom domain. for this to work, you will need a hosted zone for the specified domain name in your aws account."
  type = object({
    name                = string
    enable_for_auth     = optional(bool, true)
    enable_for_http     = optional(bool, true)
    enable_for_ws       = optional(bool, true)
    deploy_to_subdomain = optional(string)
    catch_all_email     = optional(string)
  })
  default = null
}

variable "logging" {
  type = object({
    retention_in_days = optional(number, 3)
  })
  default = {}
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
    css_content             = optional(string)
    image_base64_content    = optional(string)
    admin_registration_only = optional(bool, false)
    extra_redirect_urls     = optional(list(string))

    post_authentication_trigger = optional(object({
      source_dir    = string
      source_bucket = optional(string)
      handler       = string
      runtime       = string
      timeout       = optional(number)
      memory_size   = number
      environment   = optional(map(string))
      vpc_config = optional(object({
        subnet_ids         = list(string)
        security_group_ids = list(string)
      }))
    }))

    post_confirmation_trigger = optional(object({
      source_dir    = string
      source_bucket = optional(string)
      handler       = string
      runtime       = string
      timeout       = optional(number)
      memory_size   = number
      environment   = optional(map(string))
      vpc_config = optional(object({
        subnet_ids         = list(string)
        security_group_ids = list(string)
      }))
    }))

    pre_authentication_trigger = optional(object({
      source_dir    = string
      source_bucket = optional(string)
      handler       = string
      runtime       = string
      timeout       = optional(number)
      memory_size   = number
      environment   = optional(map(string))
      vpc_config = optional(object({
        subnet_ids         = list(string)
        security_group_ids = list(string)
      }))
    }))

    pre_sign_up_trigger = optional(object({
      source_dir    = string
      source_bucket = optional(string)
      handler       = string
      runtime       = string
      timeout       = optional(number)
      memory_size   = number
      environment   = optional(map(string))
      vpc_config = optional(object({
        subnet_ids         = list(string)
        security_group_ids = list(string)
      }))
    }))
  })
  default = null
}

variable "website" {
  description = "website module with cloudfront and s3"
  type = object({
    source_dir                  = string
    source_bucket               = optional(string)
    index_file                  = optional(string, "index.html")
    error_file                  = optional(string, "error.html")
    cache_files_regex           = optional(string, "")
    cache_files_max_age         = optional(number, 31536000)
    environment                 = optional(map(string))
    rewrites                    = optional(map(string))
    content_security_policy     = optional(string)
    auth_token_in_local_storage = optional(bool, true)
  })
  default = null
}

variable "http" {
  description = "http module with api gateway http"
  type = object({
    allow_unauthenticated = optional(bool, true)
    extra_allow_origins   = optional(list(string))
    api = optional(object({
      source_dir    = string
      source_bucket = optional(string)
      handler       = string
      runtime       = string
      timeout       = optional(number, 30)
      memory_size   = number
      environment   = optional(map(string))
      vpc_config = optional(object({
        subnet_ids         = list(string)
        security_group_ids = list(string)
      }))
    }))

    rpc = optional(object({
      source_dir    = string
      source_bucket = optional(string)
      handler       = string
      runtime       = string
      timeout       = optional(number, 30)
      memory_size   = number
      environment   = optional(map(string))
      vpc_config = optional(object({
        subnet_ids         = list(string)
        security_group_ids = list(string)
      }))
    }))
  })
  default = null
}

variable "ws" {
  description = "ws module with api gateway websocket"
  type = object({
    allow_unauthenticated = optional(bool, true)
    rpc = optional(object({
      source_dir    = string
      source_bucket = optional(string)
      handler       = string
      runtime       = string
      timeout       = optional(number, 30)
      memory_size   = number
      environment   = optional(map(string))
      vpc_config = optional(object({
        subnet_ids         = list(string)
        security_group_ids = list(string)
      }))
    }))

    event_authorizer = optional(object({
      source_dir    = string
      source_bucket = optional(string)
      handler       = string
      runtime       = string
      timeout       = optional(number, 5)
      memory_size   = number
      environment   = optional(map(string))
      vpc_config = optional(object({
        subnet_ids         = list(string)
        security_group_ids = list(string)
      }))
    }))
  })
  default = null
}

locals {
  module_name = replace(basename(abspath(path.module)), "_", "-")

  prefix = var.name_prefix == null ? "fun-${local.module_name}-${var.stage}" : var.name_prefix

  domain         = var.domain == null ? null : (var.domain.deploy_to_subdomain == null || var.domain.deploy_to_subdomain == "" ? var.domain.name : "${var.domain.deploy_to_subdomain}.${var.domain.name}")
  domain_website = local.domain
  domain_auth    = local.domain == null ? null : var.domain.enable_for_auth ? "auth.${local.domain}" : null
  domain_ws      = local.domain == null ? null : var.domain.enable_for_ws ? "ws.${local.domain}" : null
  domain_http    = local.domain == null ? null : var.domain.enable_for_http ? "api.${local.domain}" : null

  url_website  = length(module.website) > 0 ? (local.domain_website == null ? module.website[0].url : "https://${local.domain_website}") : null
  url_auth     = length(module.auth) > 0 ? (local.domain_auth == null ? module.auth[0].url : "https://${local.domain_auth}") : null
  url_auth_idp = length(module.auth) > 0 ? module.auth[0].idp_url : null
  url_ws       = length(module.ws) > 0 ? (local.domain_ws == null ? module.ws[0].url : "wss://${local.domain_ws}") : null
  url_http     = length(module.http) > 0 ? (local.domain_http == null ? module.http[0].url : "https://${local.domain_http}") : null

  auth_redirect_urls = compact(concat([local.url_website, local.url_http == null ? null : "${local.url_http}/oauth2-redirect.html"], flatten([var.auth == null ? null : var.auth.extra_redirect_urls])))

  http_allow_origins = compact(concat([local.url_website], flatten([var.http == null ? null : var.http.extra_allow_origins])))
}
