variable "domain" {
  type = string
}

variable "sub_domains" {
  type = list(string)
}

variable "hosted_zone_id" {
  type = string
}
