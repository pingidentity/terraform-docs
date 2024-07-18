locals {
  pingone_environment_name = var.append_date_to_environment_name ? format("%s %s", var.pingone_environment_name, formatdate("YYYY-MMM-DD hhmm", time_static.current.id)) : var.pingone_environment_name
}

resource "pingone_environment" "my_environment" {
  name        = local.pingone_environment_name
  description = "This environment was created by Terraform as an example of how to configure the Self-Service application."
  type        = "SANDBOX"
  license_id  = var.pingone_environment_license_id

  services = [{
    type = "SSO"
  }]
}

resource "time_static" "current" {}