output "bucket" {
  value = aws_s3_bucket.website.bucket
}

output "url" {
  value = "https://${aws_cloudfront_distribution.website.domain_name}"
}
