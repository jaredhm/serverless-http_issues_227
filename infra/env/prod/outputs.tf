output "static_bucket" {
  value = module.application.static_bucket
}
output "site_url" {
  value = module.application.site_url
}
output "site_dist_dir" {
  value = local.dist_dir
}