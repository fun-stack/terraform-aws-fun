terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.18.0, < 5"
      configuration_aliases = [aws, aws.us-east-1]
    }
  }
}
