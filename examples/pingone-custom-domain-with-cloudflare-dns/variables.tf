variable "pingone_environment_name" {
  description = "A string that represents the name of the PingOne customer environment to create and manage with Terraform."
  type        = string
  default     = "Terraform Example - Custom Domain with Cloudflare DNS"
}

variable "append_date_to_environment_name" {
  description = "A boolean that determines whether to append the current date to the pingone_environment_name value."
  type        = bool
  default     = true
}

variable "pingone_environment_license_id" {
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