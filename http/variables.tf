variable "prefix" {
  type = string
}

variable "auth_module" {
  type = any
}

variable "domain" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "source_dir" {
  type = string
}

variable "timeout" {
  type = number
}

variable "memory_size" {
  type = number
}

variable "runtime" {
  type = string
}

variable "handler" {
  type = string
}

variable "swagger_yaml_file" {
  type = string
}

variable "environment" {
  type = map(string)
}

locals {
  http_zip_file = "${path.module}/http.zip"

  swagger_yaml_decoded = yamldecode(file(var.swagger_yaml_file))

  swagger_api_integration = {
    credentials          = aws_iam_role.httpapi.arn
    timeoutInMillis      = var.timeout * 1000
    type                 = "aws_proxy"
    uri                  = aws_lambda_function.http.invoke_arn
    connectionType       = "INTERNET"
    httpMethod           = "POST"
    payloadFormatVersion = "2.0"
  }

  swagger_yaml_patched = yamlencode(merge(local.swagger_yaml_decoded, { paths = { for path_key, path_value in local.swagger_yaml_decoded.paths : path_key => { for method_key, method_value in path_value : method_key => merge(method_value, { "x-amazon-apigateway-integration" = merge(local.swagger_api_integration, lookup(method_value, "x-amazon-apigateway-integration", null)) }) } } }))
}
