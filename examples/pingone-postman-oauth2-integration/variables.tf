variable "pingone_environment_license_id" {
  description = "The license ID to use for the PingOne environment.  For more information about finding the license ID, see https://terraform.pingidentity.com/getting-started/pingone/#finding-required-ids"
  type        = string

  validation {
    condition     = var.pingone_environment_license_id != null && can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.pingone_environment_license_id))
    error_message = "The pingone_environment_license_id value must be a valid PingOne resource ID, which is a UUID format."
  }
}

variable "pingone_environment_name" {
  description = "A string that represents the name of the PingOne customer environment to create and manage with Terraform."
  type        = string
  default     = "Terraform Example - Postman OAuth 2.0 authorization type integration"
}

variable "append_date_to_environment_name" {
  description = "A boolean that determines whether to append the current date to the pingone_environment_name value."
  type        = bool
  default     = true
}