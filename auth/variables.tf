variable "prefix" {
  type = string
}

variable "domain" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "allow_unauthenticated" {
  type = bool
}

variable "redirect_urls" {
  type = list(string)
}

locals {
  module_name         = basename(abspath(path.module))
  prefix              = "${local.prefix}-${local.module_name}"
  authorizer_zip_file = "${path.module}/authorizer.zip"
}
