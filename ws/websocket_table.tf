resource "aws_dynamodb_table" "websocket_subscriptions" {
  name         = "${local.prefix}-subscriptions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "subscription_key"
  range_key    = "connection_id"

  attribute {
    name = "connection_id"
    type = "S"
  }

  attribute {
    name = "subscription_key"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  global_secondary_index {
    name            = "connection_id"
    hash_key        = "connection_id"
    range_key       = "subscription_key"
    projection_type = "KEYS_ONLY"
  }
}
