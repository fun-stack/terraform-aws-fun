data "aws_route53_zone" "domain" {
  count = var.domain == null ? 0 : 1
  name  = var.domain.name
}
