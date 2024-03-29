provider "aws" {
  region                      = "eu-central-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

provider "aws" {
  alias                       = "us-east-1"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}
