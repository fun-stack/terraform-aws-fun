output "api_role" {
  value = one(module.lambda_api[*].role)
}

output "rpc_role" {
  value = one(module.lambda_rpc[*].role)
}

output "url" {
  value = "${aws_apigatewayv2_api.httpapi.api_endpoint}/latest/"
}
