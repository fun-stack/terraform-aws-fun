module "website" {
  count  = local.website == null ? 0 : 1
  source = "./website"

  prefix = local.prefix

  domain         = local.domain_website
  hosted_zone_id = one(data.aws_route53_zone.domain[*].zone_id)

  content_security_policy = local.website.content_security_policy

  source_dir          = local.website.source_dir
  source_bucket       = local.website.source_bucket
  index_file          = local.website.index_file
  error_file          = local.website.error_file
  cache_files_regex   = local.website.cache_files_regex
  cache_files_max_age = local.website.cache_files_max_age
  rewrites            = local.website.rewrites

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}

resource "aws_s3_bucket_object" "config_file_js" {
  count = local.website == null ? 0 : 1

  bucket  = module.website[0].bucket
  key     = "app_config.js"
  content = local.app_config_js

  cache_control = "no-cache"
  content_type  = "application/javascript"
}

resource "aws_s3_bucket_object" "config_file_json" {
  count = local.website == null ? 0 : 1

  bucket  = module.website[0].bucket
  key     = "app_config.js"
  content = local.app_config_json

  cache_control = "no-cache"
  content_type  = "application/json"
}
