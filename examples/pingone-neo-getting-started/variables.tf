variable "pingone_license_id" {
  description = "A valid license UUID to apply to the new environment."
  type        = string
}

variable "pingone_admin_email" {
  description = "The email address of an administrator in the existing Administors environment."
  type        = string
}

variable "pingone_admin_env" {
  description = "The environment UUID of the existing Administrators environment."
  type        = string
}

