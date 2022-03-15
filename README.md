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

## Troubleshooting

There are some errors that can occur, when switching between different configurations and/or updating the terraform module.

### Cognito User Pool UI Customization

Error:
```
error getting Cognito User Pool UI customization (UserPoolId: eu-central-1_8XFDUWI6X, ClientId: 7sqg5mh9ou6f917imeh0fskav8): InvalidParameterException: There has to be an existing domain associated with this user pool
```

Solution:
```sh
terraform state rm $(terraform state list | grep -F ".module.auth[0].aws_cognito_user_pool_ui_customization.hosted_ui[0]")
```

### Cognito User Pool Domain

Error:
```
Error creating Cognito User Pool Domain: InvalidParameterException: Custom domain is not a valid subdomain: Was not able to resolve the root domain, please ensure an A record exists for the root domain.
```

Solution:
```sh
terraform apply # just retry
```

### Cloudfront Distribution

Error:
```
error updating CloudFront Distribution (E290PULR94BUXK): PreconditionFailed: The request failed because it didn't meet the preconditions in one or more request-header fields.
```

Solution:
```sh
terraform apply # just retry
```

### API Gateway Domain Name

Error:
```
error creating API Gateway v2 domain name (ws.fun-stack.org): BadRequestException: Certificate arn:aws:acm:eu-central-1:243903727126:certificate/acdfabc1-200b-428b-9ffb-e811fdfc7901 in account 243903727126 not yet issued (Service: AWSCertificateManager; Status Code: 400; Error Code: RequestInProgressException; Request ID: 7b8baaf4-d3ac-44c1-a581-5b12c8d3d13a; Proxy: null)`
```

Solution:
```sh
terraform apply # just retry
```

## Modules

### Auth

Cognito user-pool with hosted UI.

### Websocket-Api

(Authorized) Websocket with API Gateway.

### HTTP-Api

(Authorized) Http with API Gateway.

### Website

Cloudfront, backed by s3 bucket.
