resource "aws_s3_bucket" "website_www" {
  bucket_prefix = "${local.prefix}-website-www"
  acl           = "public-read"

  website {
    redirect_all_requests_to = "https://${local.domain_website}"
  }
}

resource "aws_cloudfront_distribution" "website_www" {
  origin {
    domain_name = aws_s3_bucket.website_www.website_endpoint
    origin_id   = aws_s3_bucket.website_www.id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["www.${local.domain_website}"]

  #TODO
  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website_www.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website_www.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

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

resource "aws_route53_record" "website_www" {
  name    = "www.${local.domain_website}"
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.website_www.domain_name
    zone_id                = aws_cloudfront_distribution.website_www.hosted_zone_id
  }
}
