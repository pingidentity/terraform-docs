module "pingone_utils" {
  source  = "pingidentity/utils/pingone"
  version = "0.0.7"

  region         = pingone_environment.my_environment.region
  environment_id = pingone_environment.my_environment.id
}

resource "pingone_system_application" "pingone_self_service" {
  environment_id = pingone_environment.my_environment.id

  type    = "PING_ONE_SELF_SERVICE"
  enabled = true

  # Set default theme styling.  Branding can be modified using the `pingone_branding_theme` and `pingone_branding_theme_default` resources.
  apply_default_theme         = true
  enable_default_theme_footer = true
}

resource "pingone_application_resource_grant" "pingone_self_service_grants" {
  environment_id = pingone_environment.my_environment.id
  application_id = pingone_system_application.pingone_self_service.id

  resource_name = module.pingone_utils.pingone_resource_name_pingone_api

  # Grant the relevant scopes using the Utilities helper module (https://registry.terraform.io/modules/pingidentity/utils/pingone/latest)
  scope_names = concat(
    # Manage Profile
    module.pingone_utils.pingone_self_service_capability_scopes_manage_profile,

    # Manage Authentication
    module.pingone_utils.pingone_self_service_capability_scopes_manage_authentication,

    # Enable or Disable MFA
    module.pingone_utils.pingone_self_service_capability_scopes_manage_mfa,

    # Change Password
    module.pingone_utils.pingone_self_service_capability_scopes_manage_password,

    # Manage Linked Accounts
    module.pingone_utils.pingone_self_service_capability_scopes_manage_linked_accounts,

    # Manage Sessions
    module.pingone_utils.pingone_self_service_capability_scopes_manage_sessions,

    # View Agreements
    module.pingone_utils.pingone_self_service_capability_scopes_view_agreements,

    # Manage OAuth Consents
    module.pingone_utils.pingone_self_service_capability_scopes_manage_oauth_consents
  )
}