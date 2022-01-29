variable "prefix" {
  type = string
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

variable "source_dir" {
  type = string
}

variable "source_bucket" {
  type = string
}

variable "timeout" {
  type = number
}

variable "memory_size" {
  type = number
}

variable "runtime" {
  type = string
}

variable "handler" {
  type = string
}

variable "environment" {
  type = map(string)
}

variable "allow_unauthenticated" {
  type = bool
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"
  ws_zip_file = "${path.module}/${local.prefix}.zip"

  websocket_connections_index_name = "user_id_index"
}
