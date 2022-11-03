module "website" {
  count  = var.website == null ? 0 : 1
  source = "./website"

  prefix = local.prefix

  domain         = local.domain_website
  hosted_zone_id = one(data.aws_route53_zone.domain[*].zone_id)

  content_security_policy = var.website.content_security_policy

  index_file = var.website.index_file
  error_file = var.website.error_file
  rewrites   = var.website.rewrites

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
