resource "aws_s3_bucket" "website" {
  bucket_prefix = "${substr(local.prefix, 0, 28)}-website"
  acl           = "private"
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.website.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.website.arn}/*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.website.iam_arn}"
            },
            "Action": "s3:ListBucket",
            "Resource": "${aws_s3_bucket.website.arn}"
        }
    ]
}
EOF
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "${local.prefix}-website"
}

resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.website.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_root_object = var.index_file
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/${var.error_file}"
  }

  aliases = var.domain == null ? [] : [
    var.domain,
    "www.${var.domain}"
  ]

  #TODO
  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn            = length(module.dns) > 0 ? module.dns[0].certificate_arn : null
    ssl_support_method             = length(module.dns) > 0 ? "sni-only" : null
    minimum_protocol_version       = length(module.dns) > 0 ? "TLSv1.2_2021" : null
    cloudfront_default_certificate = length(module.dns) == 0
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_identity.website.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect_function.arn
    }

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  wait_for_deployment = true
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${local.prefix}-security-headers"

  security_headers_config {
    dynamic "content_security_policy" {
      for_each = var.content_security_policy == null ? [] : ["0"]
      content {
        content_security_policy = var.content_security_policy
        override                = true
      }
    }
    content_type_options {
      override = true
    }
    frame_options {
      override     = true
      frame_option = "DENY"
    }
    referrer_policy {
      override        = true
      referrer_policy = "no-referrer"
    }
    strict_transport_security {
      override                   = true
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = false
    }
    xss_protection {
      override   = true
      mode_block = true
      protection = true
    }
  }
  # custom_headers_config {
  #   items {
  #     header   = "X-Content-Type-Options"
  #     override = true
  #     value    = "nosniff"
  #   }

  #   items {
  #     header   = "Strict-Transport-Security"
  #     override = true
  #     value    = "max-age=63072000; includeSubDomains"
  #   }

  #   items {
  #     header   = "X-Frame-Options"
  #     override = true
  #     value    = "deny"
  #   }

  #   dynamic "items" {
  #     for_each = var.content_security_policy == null ? [] : ["0"]
  #     content {
  #       header   = "Content-Security-Policy"
  #       override = true
  #       value    = var.content_security_policy
  #     }
  #   }
  # }
}

resource "aws_cloudfront_function" "redirect_function" {
  name    = "${local.prefix}-redirect"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = <<EOF
var rewrites = ${jsonencode(var.rewrites == null ? {} : var.rewrites)};
var domain = "${var.domain == null ? "" : var.domain}";
function handler(event) {
  var request = event.request;
  var host = request.headers.host.value;

  if (domain !== "" && host !== domain) {
    var newurl = "https://" + domain + request.uri;
    var response = {
      statusCode: 302,
      statusDescription: 'Found',
      headers:
        { "location": { "value": newurl } }
    };

    return response;
  }

  var pathWithoutSlash = request.uri.substr(1, request.uri.length);
  var redirectTo = rewrites[pathWithoutSlash];
  if (redirectTo) {
    request.uri = "/" + redirectTo;
  }

  return request;
}
EOF
}

resource "aws_route53_record" "website" {
  count   = var.domain == null ? 0 : 1
  name    = var.domain
  type    = "A"
  zone_id = var.hosted_zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
  }
}

resource "aws_route53_record" "website_www" {
  count   = var.domain == null ? 0 : 1
  name    = "www.${var.domain}"
  type    = "A"
  zone_id = var.hosted_zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
  }
}

data "aws_s3_bucket_objects" "website" {
  count = var.source_bucket != null ? 1 : 0

  bucket = var.source_bucket
  prefix = var.source_dir
}

resource "aws_s3_object_copy" "website" {
  for_each = toset(var.source_bucket != null ? data.aws_s3_bucket_objects.website[0].keys : [])

  bucket = aws_s3_bucket.website.bucket
  key    = trimprefix(substr(each.key, length(var.source_dir), length(each.key)), "/")
  source = "${var.source_bucket}/${each.key}"

  cache_control = length(var.cache_files_regex) > 0 && length(regexall(var.cache_files_regex, each.key)) > 0 ? "max-age=${var.cache_files_max_age}" : "no-cache"
  content_type  = try(lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9.]+)$", each.key).extension, null), null)

  metadata_directive = "REPLACE"

  //WORKAROUND: https://github.com/hashicorp/terraform-provider-aws/issues/25477
  lifecycle {
    ignore_changes = [tags_all]
  }
}

resource "aws_s3_bucket_object" "website" {
  for_each = var.source_bucket == null ? fileset(var.source_dir, "**") : []

  bucket = aws_s3_bucket.website.bucket
  key    = each.key
  source = "${var.source_dir}/${each.key}"
  etag   = filemd5("${var.source_dir}/${each.key}")

  cache_control = length(var.cache_files_regex) > 0 && length(regexall(var.cache_files_regex, each.key)) > 0 ? "max-age=${var.cache_files_max_age}" : "no-cache"
  content_type  = try(lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.key).extension, null), null)
}
