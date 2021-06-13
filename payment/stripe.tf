resource "stripe_product" "product" {
  name = var.product
  type = "service"
}

resource "stripe_plan" "plan" {
  for_each = var.plans
  product  = stripe_product.product.id
  amount   = each.value.amount
  interval = each.value.interval
  currency = each.value.currency
}

resource "stripe_webhook_endpoint" "endpoint" {
  url = "https://mydomain.example.com/webhook"

  enabled_events = [
    "charge.succeeded",
    "charge.failed",
    "source.chargeable",
  ]
}
