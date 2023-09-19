# Get the PingOne Workforce Environment from the variable.
data "pingone_environment" "workforce_environment" {
  environment_id = var.workforce_environment_id
}

module "pingone_utils" {
  source  = "pingidentity/utils/pingone"
  version = "0.0.7"

  region         = data.pingone_environment.workforce_environment.region
  environment_id = data.pingone_environment.workforce_environment.id
}
