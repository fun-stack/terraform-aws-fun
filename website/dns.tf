module "dns" {
  count  = var.domain == null ? 0 : 1
  source = "../dns"

  domain         = var.domain
  sub_domains    = ["www"]
  hosted_zone_id = var.hosted_zone_id

  providers = {
    aws = aws.us-east-1
  }
}
