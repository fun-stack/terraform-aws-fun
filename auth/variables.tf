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
  authorizer_zip_file = "${path.module}/authorizer.zip"
}
