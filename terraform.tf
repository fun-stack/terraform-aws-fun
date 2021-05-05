terraform {
  experiments = [module_variable_optional_attrs]
}

provider "aws" {
  region = "us-east-1"
  alias  = "us"
}
