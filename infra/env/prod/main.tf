locals {
  environment = "prod"
  dist_dir    = "${path.module}/../../../dist"
}

module "application" {
  source                             = "../../template/application"
  environment                        = local.environment
  api_name                           = "serverless-http-issues-227-${local.environment}"
  site_dist_zip                      = "${local.dist_dir}/.next/handler.zip"
  site_domain                        = var.site_domain
  site_cert_arn                      = var.site_cert_arn
}
