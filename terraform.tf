terraform {
  experiments = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38.0"
    }
    stripe = {
      source  = "franckverrot/stripe"
      version = "1.8.0"
    }
  }
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

provider "stripe" {
  api_token = local.payment == null ? null : local.payment.stripe_api_token_private
}
