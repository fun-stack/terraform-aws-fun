# fun-stack

Create an opionated app environment on AWS. With website, auth, and reactive api.

This repository contains reusable terraform modules to build this app.

See Examples for how to use it:
- fun-stack-scala-example
- fun-stack-js-example

Also see client-library for helpers in your language:
- fun-stack-scala

## What is it?

## How to use?

Make a new directory for your terraform module. In a file `terraform.tf`, you have something like this:
```tf
terraform {
  backend "s3" {
    encrypt = true
    region  = "eu-central-1"
    key     = "my-app.tfstate"
    bucket  = "<my-terraform-state-bucket>"
  }
}

provider "aws" {
  region = "eu-central-1"
}
```

Then create the s3 bucket:
```
aws s3 mb s3://<my-terraform-state-bucket>
```

Create a new file `fun.tf`:
```tf
module "fun" {
  source = "github.com/cornerman/fun-stack-tf"

  domain = "<my-domain>" // there needs to exist a hosted zone with that domain name in your aws account

  website = {
    source_dir = "<directory from where to copy website files>"
  }

  api = {
    source_dir  = "<directory from where to copy lambda files>"
    handler     = "<exported handler of you lambda>"
    runtime     = "nodejs14.x"
    timeout     = 30
    memory_size = 256
  }

  auth = {
  }
}
```

Run:
```
terraform init
terraform apply
```

Go to `<my-domain>` in your browser.

## Stages

You can have multiple environments, like dev,staging,prod. Just change the terraform workspace. These environents are available online at `<workspace>.env.<my-domain>`.

## Modules

### Auth

Cognito user-pool.

### Websocket-Api

Authorized websocket with API Gateway.

### Website

Cloudfront, backed by s3 bucket.
