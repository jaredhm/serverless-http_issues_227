
// CachingOptimized default cache policy.
data "aws_cloudfront_cache_policy" "s3" {
  name = "Managed-CachingOptimized"
}
// S3Origin default origin request policy.
data "aws_cloudfront_origin_request_policy" "cors_s3" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_response_headers_policy" "cdn" {
  name = "${var.environment}-site-headers"
  security_headers_config {
    strict_transport_security {
      # Setting this to 1 month. This can definitely be extended in the future,
      # just wanna be sure we don't shoot ourselves in the foot for > 1 month.
      access_control_max_age_sec = 2592000
      override                   = false
    }
    content_type_options {
      override = false
    }
    referrer_policy {
      override        = false
      referrer_policy = "origin"
    }
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = false
    }
    content_security_policy {
      content_security_policy = "default-src 'self' https:; script-src 'self' 'unsafe-inline' https://www.googletagmanager.com/ https://www.google-analytics.com/ https://browser-update.org/ https://js-agent.newrelic.com/ https://gov-bam.nr-data.net/; base-uri 'none'; form-action 'none'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com/ https://unpkg.com/"
      override                = false
    }
  }
  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      override = false
      value    = "interest-cohort=()"
    }
    dynamic "items" {
      for_each = var.environment == "prod" ? [] : ["noindex"]
      content {
        header   = "X-Robots-Tag"
        override = true
        value    = items.value
      }
    }
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "serverless-http test site (${var.environment})"
  aliases         = var.site_domain == null ? [] : [var.site_domain]
  default_cache_behavior {
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "default"
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cdn.id
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    path_pattern               = "/_next/static/*"
    target_origin_id           = "bucket"
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    cache_policy_id            = data.aws_cloudfront_cache_policy.s3.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.cors_s3.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cdn.id
  }
  origin {
    domain_name = replace(aws_apigatewayv2_api.backend.api_endpoint, "https://", "")
    origin_id   = "default"
    origin_path = "/default"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  origin {
    origin_id   = "bucket"
    domain_name = aws_s3_bucket.static.bucket_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static.cloudfront_access_identity_path
    }
  }
  // Custom cert.
  dynamic "viewer_certificate" {
    for_each = var.site_cert_arn == null ? [] : [1]
    content {
      cloudfront_default_certificate = false
      acm_certificate_arn            = var.site_cert_arn
      ssl_support_method             = "sni-only"
      minimum_protocol_version       = "TLSv1.2_2021"
    }
  }
  // Fallback if no cert is given
  dynamic "viewer_certificate" {
    for_each = var.site_cert_arn == null ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

/**
 * Defines the static bucket, used for static resources
 */
resource "aws_cloudfront_origin_access_identity" "static" {
  comment = "Cloudfront OAI for serverless-http-issues-227 static bucket"
}
resource "aws_s3_bucket" "static" {
  bucket_prefix = "serverless-http-issues-227"
}
resource "aws_s3_bucket_ownership_controls" "static" {
  bucket = aws_s3_bucket.static.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "static" {
  bucket = aws_s3_bucket.static.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.static]
}
resource "aws_s3_bucket_public_access_block" "static" {
  bucket              = aws_s3_bucket.static.id
  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
}
data "aws_iam_policy_document" "oai_access_static" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.static.arn}/*"]
    principals {
      identifiers = [aws_cloudfront_origin_access_identity.static.iam_arn]
      type        = "AWS"
    }
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.static.arn]
    principals {
      identifiers = [aws_cloudfront_origin_access_identity.static.iam_arn]
      type        = "AWS"
    }
  }
}
resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.oai_access_static.json
}
resource "aws_s3_bucket_website_configuration" "static" {
  bucket = aws_s3_bucket.static.id
  index_document {
    suffix = "html"
  }
}
