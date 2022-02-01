variable "prefix" {
  type = string
}

variable "log_retention_in_days" {
  type = number
}

variable "auth_module" {
  type = any
}

variable "domain" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "rpc" {
  type = object({
    source_dir    = string
    source_bucket = optional(string)
    handler       = string
    runtime       = string
    timeout       = number
    memory_size   = number
    environment   = optional(map(string))
  })
}

variable "allow_unauthenticated" {
  type = bool
}

variable "event_authorizer" {
  type = object({
    source_dir    = string
    source_bucket = optional(string)
    handler       = string
    runtime       = string
    timeout       = number
    memory_size   = number
    environment   = optional(map(string))
  })
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"
}
