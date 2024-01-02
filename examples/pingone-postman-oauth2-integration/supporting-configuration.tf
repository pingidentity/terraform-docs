locals {
  pingone_environment_name = var.append_date_to_environment_name ? format("%s %s", var.pingone_environment_name, formatdate("YYYY-MMM-DD hhmm", time_static.current.id)) : var.pingone_environment_name
}

resource "pingone_image" "postman_logo" {
  environment_id = pingone_environment.my_environment.id

  image_file_base64 = filebase64("./postman-logo.png")
}

resource "pingone_environment" "my_environment" {
  name        = local.pingone_environment_name
  description = "This environment was created by Terraform as an example of how to configure an application in PingOne integrates with Postman's OAuth 2.0 authorization type."
  type        = "SANDBOX"
  license_id  = var.pingone_environment_license_id

  service {
    type = "SSO"
  }
}

module "pingone_utils" {
  source  = "pingidentity/utils/pingone"
  version = "0.0.8"

  region         = pingone_environment.my_environment.region
  environment_id = pingone_environment.my_environment.id
}

resource "time_static" "current" {}