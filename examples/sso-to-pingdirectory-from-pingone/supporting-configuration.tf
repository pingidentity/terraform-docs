locals {
  pingone_environment_name = var.append_date_to_environment_name ? format("%s %s", var.pingone_environment_name, formatdate("YYYY-MMM-DD hhmm", time_static.current.id)) : var.pingone_environment_name
}

module "pingone_utils" {
  source  = "pingidentity/utils/pingone"
  version = "0.0.7"

  region         = pingone_environment.my_environment.region
  environment_id = pingone_environment.my_environment.id
}

resource "time_static" "current" {}