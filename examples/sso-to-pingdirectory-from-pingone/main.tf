###########################################
# Setting up SSO to PingDirectory from PingOne
#
# This example shows how to set up SSO to PingDirectory from PingOne.
# Reference: https://docs.pingidentity.com/r/en-us/pingone/pd_ds_set_up_sso_pingdir_pingone
###########################################

locals {
  pingdirectory_login_path = var.pingdirectory_ldap_host != null && var.pingdirectory_ldap_host != "" && var.pingdirectory_ldaps_port != null ? format("?ldap-hostname=%s&ldaps-port=%s", var.pingdirectory_ldap_host, var.pingdirectory_ldaps_port) : format("/login")
}

# Create the environment
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pingone_t_create_pingone_environment
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pingone_add_pingdirectory_to_the_environment
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pingone_link_pingone_to_pingdirectory
resource "pingone_environment" "my_environment" {
  name        = local.pingone_environment_name
  description = "This environment was created by Terraform as an example of how to set up SSO to PingDirectory from PingOne."
  type        = "SANDBOX"
  license_id  = var.pingone_environment_license_id

  default_population {}

  service {
    type = "SSO"
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
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pingone_configure_matching_administrator_accounts
resource "pingone_user" "demo_admin" {
  environment_id = pingone_environment.my_environment.id

  population_id = pingone_population.pingdirectory_admins.id

  username = "demouser1"
  email    = "foouser@pingidentity.com"

  name = {
    family = "User1"
    given  = "Demo"
  }
}

resource "pingdirectory_root_dn_user" "demo_admin" {
  name          = pingone_user.demo_admin.username
  email_address = pingone_user.demo_admin.email
  first_name    = pingone_user.demo_admin.name.given
  last_name     = pingone_user.demo_admin.name.family

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
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pingone_add_the_oidc_application
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
# Ref: https://docs.pingidentity.com/r/en-us/pingone/pingone_configure_the_application_in_pingdirectory
resource "pingdirectory_id_token_validator" "pingone_token_validator" {
  name                   = "PingOne ID Token Validator"
  type                   = "ping-one"
  issuer_url             = module.pingone_utils.pingone_environment_issuer
  enabled                = true
  identity_mapper        = "All Admin Users"
  evaluation_order_index = 1
}

resource "pingdirectory_default_web_application_extension" "console_web_application_extension" {
  name = "Console"

  sso_enabled        = true
  oidc_client_id     = pingone_application.pingdirectory_admin_console.oidc_options[0].client_id
  oidc_client_secret = pingone_application.pingdirectory_admin_console.oidc_options[0].client_secret
  oidc_issuer_url    = module.pingone_utils.pingone_environment_issuer
}
