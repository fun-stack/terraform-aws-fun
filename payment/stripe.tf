resource "stripe_product" "product" {
  name = var.product
  type = "service"
}

resource "stripe_price" "price" {
  for_each       = var.prices
  product        = stripe_product.product.id
  billing_scheme = "per_unit"
  nickname       = each.key
  currency       = each.value.currency
  unit_amount    = each.value.amount
  recurring = {
    interval       = each.value.interval
    interval_count = 1
  }
}

resource "stripe_webhook_endpoint" "endpoint" {
  url = "https://${var.domain}/webhook"

  enabled_events = [
    "charge.succeeded",
    "charge.failed",
    "source.chargeable",
  ]
}
