variable "prefix" {
  type = string
}

variable "domain" {
  type = string
}

variable "css_file" {
  type = string
}

variable "image_file" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "redirect_urls" {
  type = list(string)
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"
}
