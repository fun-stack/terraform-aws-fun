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

variable "allow_origins" {
  type = list(string)
}

variable "hosted_zone_id" {
  type = string
}

variable "api" {
  type = object({
    source_dir    = string
    source_bucket = optional(string)
    handler       = string
    runtime       = string
    timeout       = number
    memory_size   = number
    environment   = optional(map(string))
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }))
  })
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
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }))
  })
}

variable "allow_unauthenticated" {
  type = bool
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"
}
