#!/bin/sh

set -e

cd $(dirname "$0")

# HACK: because we are overwriting the providers in the modules terraform.tf, which we should not do...
original_content="$(cat ../provider.tf)"

cat <<EOF > ../provider.tf
provider "aws" {
  region                      = "eu-central-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_force_path_style         = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

provider "aws" {
  alias = "us"
  region = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_force_path_style         = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}
EOF
#END HACK

terraform init
terraform plan

# HACK: restore original content
echo "$original_content" > ../provider.tf
