# Terraform Writing Best Practices - PingOne

The following provides a set of best practices to apply when writing Terraform with the PingOne Terraform provider and associated modules.

These guidelines do not intend to educate on the use of Terraform, nor are they a getting started guide.  For more information about Terraform, visit [Hashicorp's Online Documentation](https://developer.hashicorp.com/terraform/docs).  To get started with Ping Identity Terraform providers, visit the online [Getting Started](./../index.md) guides.

## Platform Secrets

### Regularly Rotate Worker Application Secrets

In PingOne, administration management functions against the API can be performed by "worker" applications with admin roles assigned (as described in [online documentation](https://docs.pingidentity.com/r/en-us/pingone/p1_t_configurerolesforworkerapplication)).  To use these worker applications, there may be a need to generate an application secret and use that secret in downstream applications and services.  It is recommended to rotate these secrets on a regular basis to help mitigate against unauthorised platform changes.

Rotation can be controlled by a secrets engine that can update with the relevant API, as described in the [API documentation](https://apidocs.pingidentity.com/pingone/platform/v1/api/#post-update-application-secret), but can also be rotated through the Terraform process.

For example, the following Terraform code will rotate an application secret for the application "My Awesome App" every 30 days:
```terraform
resource "pingone_application" "my_application" {
  name = "My Awesome App"
  enabled        = true

  oidc_options {
    type                        = "WORKER"
    grant_types                 = ["CLIENT_CREDENTIALS"]
    token_endpoint_authn_method = "CLIENT_SECRET_BASIC"
  }

  # ... other configuration parameters
}

resource "time_rotating" "application_secret_rotation" {
  rotation_days = 30
}

resource "pingone_application_secret" "foo" {
  environment_id = pingone_environment.my_environment.id
  application_id = pingone_application.my_application.id

  regenerate_trigger_values = {
    "rotation_rfc3339" : time_rotating.application_secret_rotation.rotation_rfc3339,
  }
}
```

## Protect Service Configuration and Data

### Review the `force_delete_production_type` Provider Parameter

The PingOne Terraform provider has a provider-level parameter named `force_delete_production_type`.  For more details review the [registry documentation](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#force_delete_production_type) of this parameter.

The purpose of the parameter is to override the API level restriction of not being able to destroy environments of type "PRODUCTION".  The default value of this parameter is `false`, meaning that environments will not be force-deleted if the `pingone_environment` resource has a destroy plan when run in the `terraform apply` phase.  The parameter is designed to help facilitate development and testing and should be set to `false` for environments that carry production data.  Misuse of the parameter may lead to unintended data loss and must be used with caution.

### Protect Configuration and Data with the `lifecycle.prevent_destroy` Meta Argument

While some resources are safe to remove and replace, there are some resources that, if removed, can result in data loss.

It's recommended to use the `lifecycle.prevent_destroy` meta argument to protect against accidental destroy plans that might cause data to be lost.  You may also want to use the meta argument to prevent accidental removal of access policies and applications if dependent applications cannot be updated with Terraform in case of replacement.

For example:
```terraform
resource "pingone_schema_attribute" "my_attribute" {
  environment_id = pingone_environment.my_environment.id

  name         = "myAttribute"
  
  # ... other configuration parameters

  lifecycle {
    prevent_destroy = true
  }
}
```

The following resources, if destroyed, put data at risk within a PingOne environment:

* `pingone_schema_attribute`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/schema_attribute" target="_blank">:octicons-link-external-16:</a> - If a custom schema attribute is created, a destroy of the schema attribute will erase that attribute's data for users.
* `pingone_population`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/population" target="_blank">:octicons-link-external-16:</a> - Users must belong to a population.  If a population is removed, the users within that population may be at risk.  There are platform controls to prevent accidental deletion of a population that contains users.
* `pingone_environment`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/environment" target="_blank">:octicons-link-external-16:</a> - Users may belong to the environment's default population.  If the environment is removed, the users within that population may be at risk.  There are platform API level controls to prevent accidental deletion of an environment where the environment's type is set to `PRODUCTION`.  `SANDBOX` environments do not have such API restriction.

## Multi-team Development

### Use "On-Demand" Sandbox Environments

## User Administrator Role Assignment

### Use Group Role Assignments Over Terraform Managed User Role Assignments