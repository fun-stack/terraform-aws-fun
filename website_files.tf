module "website_files" {
  count  = var.website == null ? 0 : 1
  source = "./website_files"

  prefix = local.prefix

  website_bucket      = module.website[0].bucket
  source_dir          = var.website.source_dir
  source_bucket       = var.website.source_bucket
  cache_files_regex   = var.website.cache_files_regex
  cache_files_max_age = var.website.cache_files_max_age

  app_config_json = local.app_config_json
}
