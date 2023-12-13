output "static_bucket" {
  value = aws_s3_bucket.static.bucket
}
output "site_url" {
  value = "https://${coalesce(var.site_domain, aws_cloudfront_distribution.cdn.domain_name)}"
}