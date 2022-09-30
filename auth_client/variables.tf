variable "prefix" {
  type = string
}

variable "css_content" {
  type = string
}

variable "image_base64_content" {
  type = string
}

variable "user_pool_id" {
  type = string
}

variable "redirect_urls" {
  type = list(string)
}

variable "api_scopes" {
  type = list(string)
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"
}
