variable "prefix" {
  type = string
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

variable "index_file" {
  type = string
}

variable "error_file" {
  type = string
}

variable "cache_files_regex" {
  type = string
}

variable "cache_files_max_age" {
  type = number
}

variable "rewrites" {
  type = map(string)
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"

  # wget --output-document mime.json https://raw.githubusercontent.com/micnic/mime.json/master/index.json
  content_type_map = jsondecode(file("${path.module}/mime.json"))
}
