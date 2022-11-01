variable "prefix" {
  type = string
}

variable "website_bucket" {
  type = string
}

variable "source_dir" {
  type = string
}

variable "source_bucket" {
  type = string
}

variable "cache_files_regex" {
  type = string
}

variable "cache_files_max_age" {
  type = number
}

variable "app_config_json" {
  type = string
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"

  # wget --output-document mime.json https://raw.githubusercontent.com/micnic/mime.json/master/index.json
  content_type_map = jsondecode(file("${path.module}/mime.json"))

  app_config_js = <<EOF
window.AppConfig = ${var.app_config_json};
EOF
}
