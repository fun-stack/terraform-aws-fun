# terraform-aws-fun

Create an opionated fun-stack app environment on AWS. With website, auth, and reactive api.

This repository contains reusable terraform modules to build this app.

## Links

Example on how to use it:
- Fun Scala Template: [example](https://github.com/fun-stack/example)

SDK library to communicate with the infrastructure in your code:
- Fun SDK Scala: [sdk-scala](https://github.com/fun-stack/sdk-scala)

See local development module for mocking the AWS infrastructure locally:
- Fun Local Environment: [local-env](https://github.com/fun-stack/local-env)

## Requirements

- terraform (>= 1.0.0)

## How to use?

Use it in your terraform deployment as a module, for example:

```tf
module "fun" {
  source  = "fun-stack/fun/aws"
  version = "?.?.?"

  stage = "prod"

  domain = {
    name = "<my-domain>" // there needs to exist a hosted zone with that domain name in your aws account
    # deploy_to_subdomain = "${terraform.workspace}.env"
  }

  website = {
    source_dir = "<directory from where to copy website files>"
  }

  ws = {
    rpc = {
        source_dir  = "<directory from where to copy lambda files>"
        handler     = "<exported handler of you lambda>"
        runtime     = "nodejs14.x"
        timeout     = 30
        memory_size = 256
    }
  }

  http = {
    api = {
        source_dir  = "<directory from where to copy lambda files>"
        handler     = "<exported handler of you lambda>"
        runtime     = "nodejs14.x"
        timeout     = 30
        memory_size = 256
    }
  }

  auth = {
  }
}
```

Custom Domain. Either register the domain in AWS or create a hosted zone in AWS (then set the Nameservers at your registrar to the values you get from the following command):
```
aws route53 create-hosted-zone --name <my-domain> --caller-reference $(date +%s)
```

Run:
```
terraform init
terraform apply
```

Go to `<my-domain>` in your browser.

## Stages

You can have multiple environments, like dev,staging,prod. Just set `stage = "<dev|staging|prod>"`. These environents can be available online at `<stage>.env.<my-domain>`.

## Modules

### Auth

Cognito user-pool with hosted UI.

### Websocket-Api

(Authorized) Websocket with API Gateway.

### HTTP-Api

(Authorized) Http with API Gateway.

### Website

Cloudfront, backed by s3 bucket.
