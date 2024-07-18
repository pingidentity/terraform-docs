###########################################
# Configuring PingOne for Windows Passwordless Login
#
# This example shows how to configure PingOne for Windows Passwordless Login using Terraform.
# Reference: https://docs.pingidentity.com/r/en-us/solution-guides/gjd1662482065453
###########################################

# Create an issuance CA Certificate for Windows Login Passwordless.
# Ref: https://docs.pingidentity.com/r/en-us/solution-guides/dcw1662482012419
resource "pingone_key" "ad_issuance_certificate" {
  environment_id = data.pingone_environment.workforce_environment.id

  name       = "Windows Passwordless Login CA"
  subject_dn = "CN=Windows Passwordless Login CA, OU=Ping Identity, O=Ping Identity, L=, ST=, C=US"

  algorithm           = "RSA"
  key_length          = 3072
  signature_algorithm = "SHA256withRSA"

  usage_type = "ISSUANCE"

  validity_period = 365
}

data "pingone_certificate_export" "ad_issuance_certificate" {
  environment_id = data.pingone_environment.workforce_environment.id

  key_id = pingone_key.ad_issuance_certificate.id
}

# Create a supporting attribute for the ObjectSID, that must have unique values.
# Ref: https://docs.pingidentity.com/r/en-us/solution-guides/tog1662482040395
resource "pingone_schema_attribute" "objectsid" {
  environment_id = data.pingone_environment.workforce_environment.id

  name         = "objectSID"
  display_name = "ObjectSID"
  description  = "ObjectSID attribute used for Windows Login Passwordless."

  type        = "STRING"
  unique      = true
  multivalued = false
}

# Create a Windows Login Passwordless Sign-on Policy
# Ref: https://docs.pingidentity.com/r/en-us/solution-guides/tog1662482040395
resource "pingone_sign_on_policy" "windows_login_passwordless" {
  environment_id = data.pingone_environment.workforce_environment.id

  name        = "windows_login_passwordless"
  description = "An example sign-on policy for Windows Login Passwordless."

  lifecycle {
    precondition {
      condition     = data.pingone_environment.workforce_environment.solution == "WORKFORCE"
      error_message = "The selected environment must be a PingOne Workforce Environment.  Windows Login Passwordless cannot be configured on non-workforce enabled environments."
    }
  }
}

resource "pingone_sign_on_policy_action" "windows_login_passwordless" {
  environment_id    = data.pingone_environment.workforce_environment.id
  sign_on_policy_id = pingone_sign_on_policy.windows_login_passwordless.id

  priority = 1

  pingid_windows_login_passwordless {
    unique_user_attribute_name = pingone_schema_attribute.objectsid.name
    offline_mode_enabled       = true
  }
}

# Create a supporting application for desktop agents to authenticate to PingOne with.
# Ref: https://docs.pingidentity.com/r/en-us/solution-guides/gjd1662482065453
resource "pingone_application" "windows_login_passwordless_app" {
  environment_id = data.pingone_environment.workforce_environment.id
  name           = "Windows Login Passwordless Desktop Agent"
  enabled        = true

  oidc_options = {
    type                       = "NATIVE_APP"
    grant_types                = ["CLIENT_CREDENTIALS"]
    token_endpoint_auth_method = "CLIENT_SECRET_BASIC"
    redirect_uris              = ["winlogin.pingone.com://callbackauth"]

    certificate_based_authentication = {
      key_id = pingone_key.ad_issuance_certificate.id
    }
  }

  lifecycle {
    precondition {
      condition     = data.pingone_environment.workforce_environment.solution == "WORKFORCE"
      error_message = "The selected environment must be a PingOne Workforce Environment.  Windows Login Passwordless cannot be configured on non-workforce enabled environments."
    }
  }
}

data "pingone_application_secret" "windows_login_passwordless_app" {
  environment_id = data.pingone_environment.workforce_environment.id
  application_id = pingone_application.windows_login_passwordless_app.id
}

resource "pingone_application_sign_on_policy_assignment" "windows_login_passwordless" {
  environment_id = data.pingone_environment.workforce_environment.id
  application_id = pingone_application.windows_login_passwordless_app.id

  sign_on_policy_id = pingone_sign_on_policy.windows_login_passwordless.id

  priority = 1
}
