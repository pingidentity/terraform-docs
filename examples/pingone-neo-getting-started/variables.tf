variable "pingone_environment_name" {
  description = "A string that represents the name of the PingOne customer environment to create and manage with Terraform."
  type        = string
  default     = "Terraform Example - Getting Started with PingOne Neo"
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