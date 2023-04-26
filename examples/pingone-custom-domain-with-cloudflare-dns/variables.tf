variable "pingone_license_id" {
  description = "A valid license UUID to apply to the new environment."
  type        = string
}

variable "cloudflare_domain_zone" {
  description = "The Cloudflare domain zone to use for the custom domain."
  type        = string
}

variable "custom_domain_cname" {
  description = "The CNAME to use for the custom domain."
  type        = string
}

variable "certificate_pem_file" {
  description = "A valid PEM encoded public certificate to apply for the custom domain in the PingOne environment."
  type        = string
}

variable "intermediate_certificates_pem_file" {
  description = "A valid PEM encoded concatenated CA and intermediate certificates that form the chain of trust for the `certificate_pem_file`."
  type        = string
}

variable "private_key_pem_file" {
  description = "A valid PEM encoded private key to apply to the PingOne environment, to initiate TLS on the custom domain."
  type        = string
  sensitive   = true
}