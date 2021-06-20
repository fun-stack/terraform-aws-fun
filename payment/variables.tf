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

variable "stripe_api_token_private" {
  type      = string
  sensitive = true
}

variable "stripe_api_token_public" {
  type      = string
  sensitive = true
}

variable "product" {
  type = string
}

variable "prices" {
  type = map(object({
    dollar   = number
    interval = string # day, week, month, year
    currency = string # usd, eur, ...
  }))
}
