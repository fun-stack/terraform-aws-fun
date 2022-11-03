terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.18.0, < 5"
      configuration_aliases = [aws]
    }
  }
}
