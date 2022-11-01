data "aws_s3_objects" "website" {
  count = var.source_bucket != null ? 1 : 0

  bucket = var.source_bucket
  prefix = var.source_dir
}

resource "aws_s3_object_copy" "website" {
  for_each = toset([for key in flatten(data.aws_s3_objects.website[*].keys) : trimprefix(substr(key, length(data.aws_s3_objects.website[0].prefix), length(key)), "/")])

  bucket = var.website_bucket
  key    = each.key
  source = "${data.aws_s3_objects.website[0].bucket}/${data.aws_s3_objects.website[0].prefix}/${each.key}"

  copy_if_none_match = true

  cache_control = length(var.cache_files_regex) > 0 && length(regexall(var.cache_files_regex, each.key)) > 0 ? "max-age=${var.cache_files_max_age}" : "no-cache"
  content_type  = try(lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9.]+)$", each.key).extension, null), null)

  metadata_directive = "REPLACE"

  # //WORKAROUND: https://github.com/hashicorp/terraform-provider-aws/issues/25477
  lifecycle {
    ignore_changes = [tags_all]
  }
}

resource "aws_s3_bucket_object" "website" {
  for_each = var.source_bucket == null ? fileset(var.source_dir, "**") : []

  bucket = var.website_bucket
  key    = each.key
  source = "${var.source_dir}/${each.key}"
  etag   = filemd5("${var.source_dir}/${each.key}")

  cache_control = length(var.cache_files_regex) > 0 && length(regexall(var.cache_files_regex, each.key)) > 0 ? "max-age=${var.cache_files_max_age}" : "no-cache"
  content_type  = try(lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.key).extension, null), null)
}

resource "aws_s3_bucket_object" "config_file_js" {
  bucket  = var.website_bucket
  key     = "app_config.js"
  content = local.app_config_js

  cache_control = "no-cache"
  content_type  = "application/javascript"
}

resource "aws_s3_bucket_object" "config_file_json" {
  bucket  = var.website_bucket
  key     = "app_config.json"
  content = var.app_config_json

  cache_control = "no-cache"
  content_type  = "application/json"
}
