# Terraform Writing Best Practices - PingOne

The following provides a set of best practices to apply when writing Terraform with the PingOne Terraform provider and associated modules.

These guidelines do not intend to educate on the use of Terraform, nor are they a getting started guide.  For more information about Terraform, visit [Hashicorp's Online Documentation](https://developer.hashicorp.com/terraform/docs).  To get started with Ping Identity Terraform providers, visit the online [Getting Started](./../index.md) guides.

## Platform Secrets

### Regularly Rotate Application Secrets

## Protect Service Configuration and Data

### Review the `force_delete_production_type` Provider Parameter

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
