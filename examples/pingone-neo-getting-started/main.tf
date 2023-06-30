######################################################################################
# Configuring PingOne Neo
#
# This example shows how to setup an introductory PingOne Neo configuration:
#   *  PingOne Verify policies for Identity Proofing
#   *  PingOne Credentials digital wallet and verifiable credentials
#
# Reference: https://neoidentity.com
######################################################################################
resource "pingone_environment" "my_environment" {
  name        = "Terraform Example - Getting Started with PingOne Neo"
  description = "This environment was created by Terraform as an example of how to set up a PingOne Verify policy and PingOne Credentials verifiable credentials configuration."
  type        = "SANDBOX"
  license_id  = var.pingone_license_id

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
    type = "Verify"
  }
  service {
    type = "Credentials"
  }
}

######################################################################################
#
# PingOne Verify
#
######################################################################################

# PingOne Verify Example Policy: Strong Identity Proofing by Government ID
resource "pingone_verify_policy" "verify_government_id_policy" {
  environment_id = pingone_environment.my_environment.id
  name           = "Example Government ID Verification Policy"
  description    = "An example policy configured to require verification by government ID and proof of ownership using facial comparison and liveness checks."

  government_id = {
    verify = "REQUIRED"
  }

  facial_comparison = {
    verify    = "REQUIRED"
    threshold = "HIGH"
  }

  liveness = {
    verify    = "REQUIRED"
    threshold = "HIGH"
  }

  transaction = {
    timeout = {
      duration  = "30"
      time_unit = "MINUTES"
    }
    data_collection = {
      timeout = {
        duration  = "15"
        time_unit = "MINUTES"
      }
    }
    data_collection_only = false
  }
}

# PingOne Verify Exampple POlicy: Phone and Email Verification Only
resource "pingone_verify_policy" "verify_device_policy" {
  environment_id = pingone_environment.my_environment.id
  name           = "Example Email and Mobile Phone Number Verification Policy"
  description    = "An example policy configured to require verification of an email address and mobile phone number using a one-time password."

  email = {
    verify = "REQUIRED"
    otp = {
      attempts = {
        count = "3"
      }
      lifetime = {
        duration  = "10"
        time_unit = "MINUTES"
      }
      deliveries = {
        count = 3
        cooldown = {
          duration  = "30"
          time_unit = "SECONDS"
        }
      }
    }
  }

  phone = {
    verify = "REQUIRED"
    create_mfa_device : true
    otp = {
      attempts = {
        count = "3"
      }
      lifetime = {
        duration  = "5"
        time_unit = "MINUTES"
      },
      deliveries = {
        count = 3
        cooldown = {
          duration  = "30"
          time_unit = "SECONDS"
        }
      }
    }
  }

  transaction = {
    timeout = {
      duration  = "30"
      time_unit = "MINUTES"
    }
    data_collection = {
      timeout = {
        duration  = "15"
        time_unit = "MINUTES"
      }
    }
    data_collection_only = false
  }
}

######################################################################################
#
# PingOne Credentials
#
######################################################################################

## assign an administrator from parent environment Identity_Data_Admin role in the
## new environment due to P1Creds service role assignment limitation
data "pingone_role" "identity_data_admin" {
  name = "Identity Data Admin"
}

data "pingone_environment" "primary_admin_env" {
  environment_id = var.pingone_admin_env
}

data "pingone_user" "primary_admin_user" {
  environment_id = data.pingone_environment.primary_admin_env.environment_id
  email          = var.pingone_admin_email
}

resource "pingone_role_assignment_user" "primary_admin_role_assignment" {
  environment_id = data.pingone_environment.primary_admin_env.id
  user_id        = data.pingone_user.primary_admin_user.id
  role_id        = data.pingone_role.identity_data_admin.id

  scope_environment_id = pingone_environment.my_environment.id

  depends_on = [pingone_environment.my_environment]
}

## Set the name of the Credential Issuer
resource "pingone_credential_issuer_profile" "my_credential_issuer" {
  name           = "PingOne Credentials Getting Started Issuer"
  environment_id = pingone_environment.my_environment.id
}

## Setup Digital Wallet Application (pre-requisite is a native application)

# prereq native app configuration
resource "pingone_application" "my_native_app" {
  environment_id = pingone_environment.my_environment.id
  name           = "PingOne Credentials Sample Wallet App"
  enabled        = true

  oidc_options {
    type                        = "NATIVE_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    pkce_enforcement            = "S256_REQUIRED"
    token_endpoint_authn_method = "NONE"
    redirect_uris = [
      "https://www.example.com/app/callback",
    ]

    mobile_app {
      bundle_id    = "com.pingidentity.PingOneWalletSample"
      package_name = "com.pingidentity.shocard"
    }
  }

}

# configure digital wallet application
resource "pingone_digital_wallet_application" "digital_wallet" {
  environment_id = pingone_environment.my_environment.id
  application_id = pingone_application.my_native_app.id
  name           = "PingOne Credentials Sample Digital Wallet App"
  app_open_url   = "https://shocard.pingone.com/appopen"
}

## Create "Getting Started" Example Credential

# configure credential type
resource "pingone_credential_type" "gettingstarted_credential" {
  environment_id = pingone_environment.my_environment.id
  title          = "Neo Demonstration"
  description    = "Getting Started Demo Credential"
  card_type      = "NeoDemonstration"

  # tip: you can use the pingone_credential_type datasource to obtain a credential template from an existing environment
  # example:  
  #
  #   data "pingone_credential_type" "existing_credential" {
  #           environment_id     = var.existing_environment_id
  #           credential_type_id = var.existing_credential_type_id
  #   }
  #
  #   assign the template to the new resource similar to:
  #   card_design_template = pingone_credential.existing_credential_type.card_design_template
  card_design_template = "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" viewBox=\"0 0 740 480\"><rect fill=\"none\" width=\"736\" height=\"476\" stroke=\"#CACED3\" stroke-width=\"3\" rx=\"10\" ry=\"10\" x=\"2\" y=\"2\"></rect><rect fill=\"$${cardColor}\" height=\"476\" rx=\"10\" ry=\"10\" width=\"736\" x=\"2\" y=\"2\"></rect><image href=\"$${backgroundImage}\" style=\"opacity:15%\" height=\"476\" rx=\"10\" ry=\"10\" width=\"736\" x=\"2\" y=\"2\"></image><image href=\"$${logoImage}\" x=\"42\" y=\"43\" height=\"90px\" width=\"90px\"></image><text fill=\"$${textColor}\" font-weight=\"450\" font-size=\"30\" x=\"160\" y=\"90\">$${cardTitle}</text><text fill=\"$${textColor}\" font-size=\"25\" font-weight=\"300\" x=\"160\" y=\"130\">$${cardSubtitle}</text><image href=\"$${fields[3].value.href}\" x=\"75\" y=\"200\" height=\"90px\" width=\"90px\"></image><text fill=\"$${textColor}\" font-weight=\"500\" font-size=\"25\" x=\"200\" y=\"220\">$${fields[1].value} $${fields[2].value}</text><text fill=\"$${textColor}\" font-weight=\"500\" font-size=\"20\" x=\"200\" y=\"250\">$${fields[0].title}: $${fields[0].value}</text></svg>"

  metadata = {
    name               = "NeoDemonstration"
    description        = "Getting Started Demo Credential"
    bg_opacity_percent = 30

    # ensure images have content-type prefix defined and are base64 encoded
    background_image = "data:image/png;base64,${filebase64("./images/gettingstarted_background.png")}"
    logo_image       = "data:image/png;base64,${file("./images/gettingstarted_logo.png")}"

    card_color = "#69747d"
    text_color = "#ffffff"

    # fields marked as visible must align to visible fields defined in card_design_template
    fields = [
      {
        type       = "Issued Timestamp"
        title      = "Credential Issuance Date"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "ID"
        attribute  = "id"
        is_visible = false
      },
      {
        type       = "Directory Attribute"
        title      = "givenName"
        attribute  = "name.given"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "surname"
        attribute  = "name.family"
        is_visible = true
      },
      {
        type       = "Directory Attribute"
        title      = "Photo"
        attribute  = "photo"
        is_visible = true
      }
    ]
  }
}

# configure issuance rule
# example uses a group for credential assignment
resource "pingone_group" "gettingstarted_assignment_group" {
  environment_id = pingone_environment.my_environment.id

  name = "Example group for Getting Started credential assignment"
}

resource "pingone_credential_issuance_rule" "gettingstarted_credential_issuance_rule" {
  environment_id                = pingone_environment.my_environment.id
  credential_type_id            = pingone_credential_type.gettingstarted_credential.id
  digital_wallet_application_id = pingone_digital_wallet_application.digital_wallet.id
  status                        = "ACTIVE"

  # users added to the group will be issued the credential after they pair their digital wallet
  filter = {
    group_ids = [pingone_group.gettingstarted_assignment_group.id]
  }

  automation = {
    issue  = "PERIODIC"
    revoke = "PERIODIC"
    update = "PERIODIC"
  }

  notification = {
    methods = ["EMAIL", "SMS"]
  }
}

## Create "VerifiedEmployee" Credential Example
## See: https://identity.foundation/jwt-vc-presentation-profile/#credential-type-verifiedemployee

# create displayName attribute used by VerifiedEmployee
data "pingone_schema" "users" {
  environment_id = pingone_environment.my_environment.id

  name = "User"

}
resource "pingone_schema_attribute" "display_name" {
  environment_id = pingone_environment.my_environment.id
  schema_id      = data.pingone_schema.users.id

  name         = "displayName"
  display_name = "Display Name"
  description  = "Custom Display Name attribute."

  type        = "STRING"
  unique      = false
  multivalued = false

}

# configure credential type
resource "pingone_credential_type" "verifiedemployee" {
  environment_id       = pingone_environment.my_environment.id
  title                = "VerifiedEmployee"
  description          = "Demo Proof of Employment"
  card_type            = "VerifiedEmployee"
  card_design_template = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 740 480\"><rect fill=\"none\" width=\"736\" height=\"476\" stroke=\"#CACED3\" stroke-width=\"3\" rx=\"10\" ry=\"10\" x=\"2\" y=\"2\"></rect><rect fill=\"$${cardColor}\" height=\"476\" rx=\"10\" ry=\"10\" width=\"736\" x=\"2\" y=\"2\" opacity=\"$${bgOpacityPercent}\"></rect><image href=\"$${backgroundImage}\" opacity=\"$${bgOpacityPercent}\" height=\"301\" rx=\"10\" ry=\"10\" width=\"589\" x=\"75\" y=\"160\"></image><image href=\"$${logoImage}\" x=\"42\" y=\"43\" height=\"90px\" width=\"90px\"></image><line y2=\"160\" x2=\"695\" y1=\"160\" x1=\"42.5\" stroke=\"$${textColor}\"></line><text fill=\"$${textColor}\" font-weight=\"450\" font-size=\"30\" x=\"160\" y=\"90\">$${cardTitle}</text><text fill=\"$${textColor}\" font-size=\"25\" font-weight=\"300\" x=\"160\" y=\"130\">$${cardSubtitle}</text></svg>"

  metadata = {
    name               = "VerifiedEmployee"
    description        = "Demo Proof of Employment"
    bg_opacity_percent = 100

    background_image = "data:image/png;base64,${file("./images/verifiedemployee_background.png")}"
    logo_image       = "data:image/png;base64,${file("./images/verifiedemployee_logo.png")}"

    card_color = "#ffffff"
    text_color = "#000000"

    fields = [
      {
        type       = "Directory Attribute"
        title      = "givenName"
        attribute  = "name.given"
        is_visible = false
      },
      {
        type       = "Directory Attribute"
        title      = "surname"
        attribute  = "name.family"
        is_visible = false
      },
      {
        type       = "Directory Attribute"
        title      = "jobTitle"
        attribute  = "title"
        is_visible = false
      },
      {
        type       = "Directory Attribute"
        title      = "displayName"
        attribute  = "displayName"
        is_visible = false
      },
      {
        type       = "Directory Attribute"
        title      = "mail"
        attribute  = "email"
        is_visible = false
      },
      {
        type       = "Directory Attribute"
        title      = "preferredLanguage"
        attribute  = "preferredLanguage"
        is_visible = false
      },
      {
        type       = "Directory Attribute"
        title      = "id"
        attribute  = "id"
        is_visible = false
      }
    ]
  }
}

# configure issuance rule
# example uses a population for credential assignment - an existing default or other population could be used
resource "pingone_population" "demo_population" {
  environment_id = pingone_environment.my_environment.id

  name        = "Demo User Population"
  description = "Demo User Population"
}

resource "pingone_credential_issuance_rule" "verified_employee_issuance_rule" {
  environment_id                = pingone_environment.my_environment.id
  credential_type_id            = pingone_credential_type.verifiedemployee.id
  digital_wallet_application_id = pingone_digital_wallet_application.digital_wallet.id
  status                        = "ACTIVE"

  filter = {
    population_ids = [pingone_population.demo_population.id]
  }

  automation = {
    issue  = "PERIODIC"
    revoke = "PERIODIC"
    update = "PERIODIC"
  }

  notification = {
    methods = ["EMAIL"]
  }
}
