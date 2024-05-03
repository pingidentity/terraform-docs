# Configuring the PingOne Self-Service Application

The following shows an example of how to configure the PingOne Self-Service system application.

The PingOne Self-Service application can be configured in the PingOne Admin Console using the [online documentation](https://docs.pingidentity.com/r/en-us/pingone/p1_c_self_service).  It is a web application and as such it's capabilities are configured by assigning resource scopes to the application, rather than through a dedicated API or Terraform resource.

First, we will need to ensure that the Self-Service application itself is configured using the `pingone_system_application`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/system_application" target="_blank">:octicons-link-external-16:</a> resource.
``` terraform
resource "pingone_system_application" "pingone_self_service" {
  environment_id = pingone_environment.my_environment.id

  type    = "PING_ONE_SELF_SERVICE"
  enabled = true
}
```

We then map the appropriate scopes to enable the specific self-service features we want using the `pingone_application_resource_grant`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/application_resource_grant" target="_blank">:octicons-link-external-16:</a> resource.
``` terraform
resource "pingone_application_resource_grant" "pingone_self_service_grants" {
  environment_id = pingone_environment.my_environment.id
  application_id = pingone_system_application.pingone_self_service.id

  resource_name = "PingOne API"

  scope_names = [
    # Manage Profile
    "p1:read:user",
    "p1:update:user",

    # Manage Authentication
    "p1:create:device",
    "p1:create:pairingKey",
    "p1:delete:device",
    "p1:read:device",
    "p1:read:pairingKey",
    "p1:update:device",

    # Enable or Disable MFA
    "p1:update:userMfaEnabled",

    # Change Password
    "p1:read:userPassword",
    "p1:reset:userPassword",
    "p1:validate:userPassword",

    # Manage Linked Accounts
    "p1:delete:userLinkedAccounts",
    "p1:read:userLinkedAccounts",

    # Manage Sessions
    "p1:delete:sessions",
    "p1:read:sessions",

    # View Agreements
    "p1:read:userConsent",
    
    # Manage OAuth Consents
    "p1:read:oauthConsent",
    "p1:update:oauthConsent",
  ]
}
```

The full runable example can be found on Github [here](https://github.com/pingidentity/terraform-docs/tree/main/examples/pingone-configuring-the-self-service-application).