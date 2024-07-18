locals {
  pingone_environment_name = var.append_date_to_environment_name ? format("%s %s", var.pingone_environment_name, formatdate("YYYY-MMM-DD hhmm", time_static.current.id)) : var.pingone_environment_name
}

resource "pingone_environment" "my_environment" {
  name        = local.pingone_environment_name
  description = "This environment was created by Terraform as an example of how to set up custom domain configuration with Cloudflare DNS."
  type        = "SANDBOX"
  license_id  = var.pingone_environment_license_id

  services = [{
    type = "SSO"
  }]
}

module "pingone_utils" {
  source  = "pingidentity/utils/pingone"
  version = "0.1.0"

  region_code    = pingone_environment.my_environment.region
  environment_id = pingone_environment.my_environment.id

  custom_domain = pingone_custom_domain.my_custom_domain.domain_name
}

resource "time_static" "current" {}