terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  default_tags = {
    funstack = local.prefix
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = local.default_tags
  }
  alias = "us"
}
