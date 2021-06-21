output "price_ids" {
  value = { for k, v in stripe_price.price : k => v.price_id }
}
