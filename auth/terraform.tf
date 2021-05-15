terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 3.38.0"
      configuration_aliases = [aws, aws.us]
    }
  }
}
