variable "name" {
  type = string
}

variable "domain" {
  type = string
}

variable "prod_workspace" {
  type    = string
  default = "prod"
}
variable "dev_workspaces" {
  type    = list(string)
  default = ["dev"]
}

variable "dev_setup" {
  type = object({
    local_website_url = string
    config_output_dir = string
  })
  default = null
}

variable "allow_unauthenticated" {
  type    = bool
  default = false
}

variable "auth" {
  type = object({
  })
}

variable "website" {
  type = object({
    source_dir = string
  })
}

variable "api" {
  type = object({
    source_dir  = string
    handler     = string
    runtime     = string
    timeout     = number
    memory_size = number
  })
}

locals {
  prefix = "${var.name}-${terraform.workspace}"

  is_dev = var.dev_setup != null && contains(var.dev_workspaces, terraform.workspace)

  domain         = terraform.workspace == var.prod_workspace ? var.domain : "${terraform.workspace}.env.${var.domain}"
  domain_website = local.domain
  domain_auth    = "auth.${local.domain}"
  domain_ws      = "api.${local.domain}"
  redirect_urls = concat(
    ["https://${local.domain_website}"],
    local.is_dev ? [var.dev_setup.local_website_url] : []
  )

  api_zip_file        = "${path.module}/api.zip"
  authorizer_zip_file = "${path.module}/authorizer.zip"

  content_type_map = {
    html = "text/html",
    js   = "application/javascript",
    css  = "text/css",
    svg  = "image/svg+xml",
    jpg  = "image/jpeg",
    ico  = "image/x-icon",
    png  = "image/png",
    gif  = "image/gif",
    pdf  = "application/pdf"
  }

  app_config = <<EOF
window.AppConfig = {
  "environment": "${terraform.workspace}",
  "domain": "${local.domain_website}",
  "domainAuth": "${local.domain_auth}",
  "domainWS": "${local.domain_ws}",
  "clientIdAuth": "${aws_cognito_user_pool_client.website_client.id}",
  "region": "${data.aws_region.current.name}",
  "identityPoolId": "${aws_cognito_identity_pool.user.id}",
  "cognitoEndpoint": "${aws_cognito_user_pool.user.endpoint}"
};
EOF
}
