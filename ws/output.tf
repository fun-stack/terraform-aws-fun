locals {
  api_gateway_url = "${aws_apigatewayv2_api.websocket.api_endpoint}/latest/"
}

output "rpc_role" {
  value = one(module.lambda_rpc[*].role)
}

output "event_authorizer_role" {
  value = one(module.lambda_event_authorizer[*].role)
}

output "url" {
  value = local.api_gateway_url
}

output "event_topic" {
  value = aws_sns_topic.subscription_events.id
}

output "event_policy_arn" {
  value = aws_iam_policy.subscription_events.arn
}
