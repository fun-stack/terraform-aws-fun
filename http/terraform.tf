terraform {
  experiments = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 3.51.0"
      configuration_aliases = [aws]
    }
  }
}
