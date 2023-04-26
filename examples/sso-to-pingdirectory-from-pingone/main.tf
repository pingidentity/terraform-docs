###########################################
# Setting up SSO to PingDirectory from PingOne
#
# This example shows how to set up SSO to PingDirectory from PingOne.
# Reference: https://docs.pingidentity.com/r/en-us/pingone/pd_ds_set_up_sso_pingdir_pingone
###########################################

locals {
  pingdirectory_login_path = var.pingdirectory_ldap_host != null && var.pingdirectory_ldap_host != "" && var.pingdirectory_ldap_port != null ? format("?ldap-hostname=%s&ldaps-port=%s", var.pingdirectory_ldap_host, var.pingdirectory_ldap_port) : format("/login")
}

# Create the environment
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pd_ds_set_up_sso_pingdir_pingone Step 1
resource "pingone_environment" "my_environment" {
  name        = "Terraform Example - Setting up SSO to PingDirectory from PingOne"
  description = "This environment was created by Terraform as an example of how to set up SSO to PingDirectory from PingOne."
  type        = "SANDBOX"
  solution    = "CUSTOMER"
  license_id  = var.license_id

  default_population {
    name        = "My Default Population"
    description = "My new population for users"
  }

  service {
    type = "SSO"
  }

  service {
    type = "MFA"
  }

  service {
    type        = "PingDirectory"
    console_url = format("%s/console%s", var.pingdirectory_console_base_url, local.pingdirectory_login_path)
  }
}

resource "pingone_population" "pingdirectory_admins" {
  environment_id = pingone_environment.my_environment.id

  name = "PingDirectory Demo Admins"
}


# Create a demo user and map it to the PingDirectory root DN user
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pd_ds_set_up_sso_pingdir_pingone Step 2
resource "pingone_user" "demo_admin" {
  environment_id = pingone_environment.my_environment.id

  population_id = pingone_population.pingdirectory_admins.id

  username = "demouser1"
  email    = "foouser@pingidentity.com"
}

resource "pingdirectory_root_dn_user" "demo_admin" {
  id            = pingone_user.demo_admin.username
  user_id       = pingone_user.demo_admin.username
  email_address = pingone_user.demo_admin.email

  inherit_default_root_privileges = true
  search_result_entry_limit       = 0
  time_limit_seconds              = 0
  look_through_entry_limit        = 0
  idle_time_limit_seconds         = 0
  password_policy                 = "Root Password Policy"
  require_secure_authentication   = false
  require_secure_connections      = false
}

# Create an application for the PingDirectory Administrative Console
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pd_ds_set_up_sso_pingdir_pingone Steps 3, 4, 5 and 6
resource "pingone_application" "pingdirectory_admin_console" {
  environment_id = pingone_environment.my_environment.id
  name           = "PingDirectory Administrative Console"
  description    = "Application for the PingDirectory Administrative Console"
  enabled        = true

  oidc_options {
    type                        = "WEB_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    token_endpoint_authn_method = "CLIENT_SECRET_BASIC"
    redirect_uris               = [format("%s/console/oidc/cb", var.pingdirectory_console_base_url)]
  }
}

resource "pingone_application_attribute_mapping" "username_mapping" {
  environment_id = pingone_environment.my_environment.id
  application_id = pingone_application.pingdirectory_admin_console.id

  name  = "sub"
  value = "$${user.username}"
}

# Configure the PingDirectory administrator console with PingOne details
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pd_ds_set_up_sso_pingdir_pingone Steps 9, 10 and 11
