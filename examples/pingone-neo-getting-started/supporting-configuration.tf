locals {
  pingone_environment_name = var.append_date_to_environment_name ? format("%s %s", var.pingone_environment_name, formatdate("YYYY-MMM-DD hhmm", time_static.current.id)) : var.pingone_environment_name
}

# example uses a group for credential assignment
resource "pingone_group" "getting_started_assignment_group" {
  environment_id = pingone_environment.my_environment.id

  name = "Example group for Getting Started credential assignment"
}

# example uses a population for credential assignment - an existing default or other population could be used
resource "pingone_population" "demo_population" {
  environment_id = pingone_environment.my_environment.id

  name        = "Demo User Population"
  description = "Demo User Population"
}

resource "pingone_image" "credentials_card_verified_employee_background_image" {
  environment_id = pingone_environment.my_environment.id

  image_file_base64 = filebase64("./images/verifiedemployee_background.png")
}

resource "pingone_image" "credentials_card_verified_employee_logo_image" {
  environment_id = pingone_environment.my_environment.id

  image_file_base64 = filebase64("./images/verifiedemployee_logo.png")
}

resource "pingone_image" "credentials_card_getting_started_background_image" {
  environment_id = pingone_environment.my_environment.id

  image_file_base64 = filebase64("./images/gettingstarted_background.png")
}

resource "pingone_image" "credentials_card_getting_started_logo_image" {
  environment_id = pingone_environment.my_environment.id

  image_file_base64 = filebase64("./images/gettingstarted_logo.png")
}

resource "pingone_environment" "my_environment" {
  name        = local.pingone_environment_name
  description = "This environment was created by Terraform as an example of how to set up a PingOne Verify policy and PingOne Credentials verifiable credentials configuration."
  type        = "SANDBOX"
  license_id  = var.pingone_environment_license_id

  default_population {}

  service {
    type = "SSO"
  }
  service {
    type = "MFA"
  }
  service {
    type = "Verify"
  }
  service {
    type = "Credentials"
  }
}

resource "time_static" "current" {}