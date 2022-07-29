#!/bin/sh

set -e

cd $(dirname "$0")

terraform init
terraform plan
