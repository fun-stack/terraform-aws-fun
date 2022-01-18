output "http_role" {
  value = aws_iam_role.lambda_http
}

output "url" {
  value = "${aws_apigatewayv2_api.httpapi.api_endpoint}/latest"
}
