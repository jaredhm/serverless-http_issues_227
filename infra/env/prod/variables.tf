variable "site_domain" {
  type        = string
  default     = null
  description = "Domain name to use for the website."
}

variable "site_cert_arn" {
  type        = string
  default     = null
  description = "ARN of the ACM cert to use for the website"
}