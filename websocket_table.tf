resource "aws_dynamodb_table" "websocket_connections" {
  name         = "${local.prefix}-websocket-connections"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "connection_id"

  attribute {
    name = "connection_id"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name            = "user_id_index"
    hash_key        = "user_id"
    range_key       = "connection_id"
    projection_type = "ALL"
  }
}
