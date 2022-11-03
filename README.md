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

- terraform (>= 1.3.0)

## How to use?

Use it in your terraform deployment as a module. Check out: [Examples](tests/)

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

### Cloudfront Distribution

Error:
```
error updating CloudFront Distribution (E290PULR94BUXK): PreconditionFailed: The request failed because it didn't meet the preconditions in one or more request-header fields.
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
