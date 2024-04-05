# Terraform Writing Best Practices - PingOne

The following sections provide a set of best practices to apply when writing Terraform with the PingOne Terraform provider and associated modules.

These guidelines do not intend to educate on the use of Terraform, nor are they a "Getting Started" guide.  For more information about Terraform, visit [Hashicorp's Online Documentation](https://developer.hashicorp.com/terraform/docs).  To get started with the PingOne Terraform provider, visit the online [PingOne provider Getting Started](./../../getting-started/pingone/) guide.

## Develop in the Admin Console, Promote using Configuration-As-Code

Ping recommends that use-case development activities are performed in the PingOne web admin console whenever possible.  This recommendation is due to the complex nature of Workforce IAM and Customer IAM deployments that includes policy definition, user experience design and associated testing/validation of designed use cases.

After having been developed in the web admin console, configuration can be extracted as configuration-as-code to be stored in source control (such as a Git code repository) and linked with CI/CD tooling to automate the delivery of use cases into test and production environments.

For professionals experienced in DevOps development, configuration may be created and altered outside of the web admin console, but care must be taken when modifying complex configuration such Authorize, MFA, Protect or SSO sign-on policies.

## Example / Bootstrapped Configuration Dependencies

### Deploy to "Clean" Environments, without Example / Bootstrapped Configuration

Example / bootstrapped configuration is deployed automatically by the PingOne service when an environment is created (or new services are provisioned to an existing environment).  This behaviour is the default of the web admin console, and the API.

Example / bootstrapped configuration may be useful as a starting point when initially creating use cases with the service (in the development phase), but will create conflicts when migrating the configuration through to test and production environments.

The definition of the example / bootstrapped configuration for new environment may also change over time, as new features are released and use case configuration best practices are defined.  Therefore, an environment created today may not be the same as an environment created a year from now.

As a result, it is best practice to create a new environment as a "clean" (without example or bootstrapped configuration) environment for those environments outside of the initial development one.  If environments cannot be re-created or are intended to be long-lasting (such as staging/pre-production or production), it may be enough to remove bootstrapped configuration manually when an environment is created.

Notable examples of demo configuration include:

#### Platform
- The default branding theme
- Optional directory schema attributes (which can be disabled if not used)
  - `accountId`
  - `address`
  - `email`
  - `externalId`
  - `locale`
  - `mobilePhone`
  - `name`
  - `nickname`
  - `photo`
  - `preferredLanguage`
  - `primaryPhone`
  - `timezone`
  - `title`
  - `type`
- The default Keys and Certificates
- The default notification policies
- The default `Single_Factor` sign-on policy
- The example password policies
- The `PingOne Application Portal` (which can be disabled if not used)

#### DaVinci service
- Example Forms

#### MFA service
- The default MFA Device Policy
- The default FIDO2 policies
- The `Multi_Factor` sign-on policy

#### Verify service
- The default verify policy

### Define All Configuration Dependencies in Terraform (or elsewhere in the Pipeline)

Example / bootstrapped configuration is deployed automatically by the PingOne service when an environment is created (or new services are provisioned to an existing environment).  This behaviour is the default of the web admin console, and the API.

Example / bootstrapped configuration may be useful as a starting point when initially creating use cases with the service (in the development phase), but will create conflicts when migrating the configuration through to test and production environments.

The definition of the example / bootstrapped configuration for new environment may also change over time, as new features are released and use case configuration best practices are defined.  Therefore, an environment created today may not be the same as an environment created a year from now.

Therefore, it is best practice to explicitly define all configuration dependencies in Terraform (or as a prior step in the CICD pipeline) after developing flows for use cases.  Most notably, this practice includes defining the policies (e.g. sign-on, MFA Device, FIDO2, Protect policies) that applications will use in HCL, rather than using the example / bootstrapped environment examples.

#### Not best practice

The below `pingone_population`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/population" target="_blank">:octicons-link-external-16:</a> definition is not best practice, as it depends on the "Passphrase" password policy that is deployed by default when the environment was created.  In this case, there is an assumption that this password policy will always exist and have a consistent definition on every environment creation.  This assumption is not correct, as the password policy may change over time.

```hcl
data "pingone_password_policy" "ootb_passphrase" {
  environment_id = pingone_environment.my_environment.id

  name = "Passphrase"
}

resource "pingone_population" "my_population" {
  environment_id = pingone_environment.my_environment.id

  name        = "My awesome population"
  description = "My new population for awesome people"

  password_policy_id = data.pingone_password_policy.ootb_passphrase.id

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}
```

#### Best practice

The below `pingone_population`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/population" target="_blank">:octicons-link-external-16:</a> definition is best practice as the password policy that it depends on is explicitly defined using the `pingone_password_policy`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/password_policy" target="_blank">:octicons-link-external-16:</a> resource.  This explicit definition will ensure that environments are built and configured consistently between development, test and production.

```hcl
resource "pingone_password_policy" "my_password_policy" {
  environment_id = pingone_environment.my_environment.id

  name        = "My awesome password policy"
  
  exclude_commonly_used_passwords = true
  exclude_profile_data            = true
  not_similar_to_current          = true

  password_history {
    prior_password_count = 6
    retention_days       = 365
  }

  # ... other configuration parameters
}

resource "pingone_population" "my_population" {
  environment_id = pingone_environment.my_environment.id

  name        = "My awesome population"
  description = "My new population for awesome people"

  password_policy_id = pingone_password_policy.my_password_policy.id

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}
```

## Protect Service Configuration and Data

The following sections detail best practices to apply to ensure protection of production data (beyond what is covered in [Secrets Management](../index.md/#secrets-management) ) when using the PingOne Terraform provider.

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

## Review use of API "force-delete" Provider Overrides

The PingOne Terraform provider has a provider-level parameter named `global_options`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#nestedblock--global_options" target="_blank">:octicons-link-external-16:</a>, that allows administrators to override API behaviours for development/test and demo purposes.  For more details review the [registry documentation](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#global-options) of this parameter.

There are two parameters that allow force-deletion of configuration, which could result in loss of data if not correctly used.

### `environment.production_type_force_delete`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#production_type_force_delete" target="_blank">:octicons-link-external-16:</a>

The purpose of the parameter is to override the API level restriction of not being able to destroy environments of type "PRODUCTION".  The default value of this parameter is `false`, meaning that environments will not be force-deleted if a `pingone_environment`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/environment" target="_blank">:octicons-link-external-16:</a> resource that has a `type` value of `PRODUCTION` has a destroy plan when run in the `terraform apply` phase.  Use of this parameter is designed to help facilitate development, testing or demonstration purposes and should be set to `false` (or left undefined) for environments that carry production data.

The implementation of this option is that the environment type will be changed from `PRODUCTION` to `SANDBOX` before a delete API request is issued.  Consider instead changing the type to `SANDBOX` manually before running a plan that destroys an environment, instead of using this parameter.

Misuse of the parameter may lead to unintended data loss and must be used with caution.

### `population.contains_users_force_delete`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#contains_users_force_delete" target="_blank">:octicons-link-external-16:</a>

The purpose of the parameter is to override the API level restriction of not being able to destroy populations that contain user data.  The default value of this parameter is `false`, meaning that populations that contain user data will not be force-deleted if a `pingone_population`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/population" target="_blank">:octicons-link-external-16:</a> resource has a destroy plan when run in the `terraform apply` phase.  Use of this parameter is designed to help facilitate development, testing or demonstration purposes where non-production user data is created and can be safely discarded.  The parameter should be set to `false` (or left undefined) for environments that carry production data.

The implementation of this option is that the provider will find and delete all users assigned to the population being destroyed, before a delete API request is issued to the population.  Consider instead removing non-production data manually before running a plan that destroys a population, instead of using this parameter.

Misuse of the parameter may lead to unintended data loss and must be used with caution.

### Protect Configuration and Data with the `lifecycle.prevent_destroy` Meta Argument

While some resources are safe to remove and replace, there are some resources that, if removed, can result in data loss.

It is recommended to use the `lifecycle.prevent_destroy` meta argument to protect against accidental destroy plans that might cause data to be lost.  You may also want to use the meta argument to prevent accidental removal of access policies and applications if dependent applications cannot be updated with Terraform in case of replacement.

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

PingOne customer tenants have a "tenant-in-tenant" architecture, whereby a PingOne tenant organisation can contain many individual environments.  These individual environments can be purposed for development, test, pre-production and production purposes.  These separate environments allow for easy maintenance of multiple development and test instances.

The recommended approach for multi-team development, when using a GitOps CICD promotion process, is to spin up "on-demand" development and test environments, specific to new features or to individual teams, to allow for development and integration testing that does not conflict with other team's development and test activities.  The Terraform provider allows administrators to use CICD automation to provision new environments as required, and remove them after the project activity no longer needs them.

In a GitOps CICD promotion pipeline, configuration can be translated to Terraform config-as-code and then merged (with Pull Requests) with common test environments, where automated tests can be run.  This flow allows the activities in the "on-demand" environments to be merged into a common promotion pipeline to production environments.

## User Administrator Role Assignment

### Use Group Role Assignments Over Terraform Managed User Role Assignments

As of 24th October 2023, the PingOne platform supports assigning [administrator roles to groups](https://docs.pingidentity.com/r/en-us/pingone/pingone_c_group_roles?tocId=eAE9ape_uu3C_DvRgojMgw), such that members of the group get the administrator roles assigned.

Ping recommends that groups with admin role assignments are controlled by the Joiner/Mover/Leaver Identity Governance processes, separate to the Terraform CICD process that configures applications, policies, domain verification and so on.  It may be that the groups with their role assignments are initially seeded by a Terraform.  In this case, it should still be a separate Terraform process to the process that controls platform configuration, and the user group assignments should still happen in the Joiner/Mover/Leaver Identity Governance process.

Terraform can be used to assign administrator roles to individuals directly, however this is not recommended best practice except in development (or generally non-production) environments.  Ping recommends that role assignment processes in non-production environments align as close as possible to role assignment processes in production environments.
