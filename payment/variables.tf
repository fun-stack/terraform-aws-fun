variable "prefix" {
  type = string
}

variable "auth_module" {
  type = any
}

variable "domain" {
  type = string
}

variable "allow_origins" {
  type = list(string)
}

variable "hosted_zone_id" {
  type = string
}

variable "stripe_api_token_private" {
  type      = string
  sensitive = true
}

variable "stripe_api_token_public" {
  type      = string
  sensitive = true
}

variable "product" {
  type = string
}

variable "prices" {
  type = map(object({
    amount   = number
    interval = string # day, week, month, year
    currency = string # usd, eur, ...
  }))
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"
}
