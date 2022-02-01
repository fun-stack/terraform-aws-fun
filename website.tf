module "website" {
  count  = local.website == null ? 0 : 1
  source = "./website"

  prefix = local.prefix

  domain         = local.domain_website
  hosted_zone_id = one(data.aws_route53_zone.domain[*].zone_id)

  source_dir          = local.website.source_dir
  source_bucket       = local.website.source_bucket
  index_file          = local.website.index_file
  error_file          = local.website.error_file
  cache_files_regex   = local.website.cache_files_regex
  cache_files_max_age = local.website.cache_files_max_age
  rewrites            = local.website.rewrites

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}

resource "aws_s3_bucket_object" "config_file" {
  count = local.website == null ? 0 : 1

  bucket  = module.website[0].bucket
  key     = "app_config.js"
  content = local.app_config_js

  cache_control = "no-cache"
  content_type  = "application/javascript"
}
