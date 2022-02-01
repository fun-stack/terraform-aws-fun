variable "prefix" {
  type = string
}

variable "log_retention_in_days" {
  type = number
}

variable "cognito_user_pool_id" {
  type = string
}

variable "cognito_api_scopes" {
  type = string
}

variable "identity_source" {
  type = string
  validation {
    condition     = var.identity_source == "HEADER" || var.identity_source == "QUERYSTRING"
    error_message = "The identity_source must be one of these values: HEADER, QUERYSTRING."
  }
}

variable "allow_unauthenticated" {
  type = bool
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"
}
