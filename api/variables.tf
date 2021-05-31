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

locals {
  api_zip_file = "${path.module}/api.zip"
}
