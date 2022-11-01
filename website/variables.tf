variable "prefix" {
  type = string
}

variable "domain" {
  type = string
}

variable "content_security_policy" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "index_file" {
  type = string
}

variable "error_file" {
  type = string
}

variable "rewrites" {
  type = map(string)
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"
}
