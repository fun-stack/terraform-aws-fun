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

Use it in your terraform deployment as a module. Check out: `tests/`

For the custom domain: Either register the domain in AWS or create a hosted zone in AWS (then set the Nameservers at your registrar to the values you get from the following command):
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

### Expected warnings

This warning is expected, you can safely ignore it.

```
│ Warning: Experimental feature "module_variable_optional_attrs" is active
│
│   on .terraform/modules/example/terraform.tf line 2, in terraform:
│    2:   experiments = [module_variable_optional_attrs]
│
│ Experimental features are subject to breaking changes in future minor or patch releases, based on feedback.
│
│ If you have feedback on the design of this feature, please open a GitHub issue to discuss it.
╵
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
