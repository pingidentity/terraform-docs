# PingOne Role Permission Assignment

The following shows an example of environment creation using the PingOne Terraform provider, followed by role permission assignment to administration users that are members of a group we will create.

!!! note "User-level Role Assignments"
    As of 24th October 2023, the PingOne platform supports assigning administrator roles groups, such that members of the group get the administrator roles assigned.  While Terraform can be used to assign administrator roles to individuals directly, Ping Identity recommends that role assignments provisioned by Terraform are assigned to groups instead, and group membership managed through Joiner/Mover/Leaver Identity Governance processes.

The example assumes that all relevant admins users will have a role strategy as follows:

* **Environment Admin**, scoped to individual environments (not scoped to the organization)
* **Identity Data Admin**, scoped to individual environments

!!! note "Variable Mapping"
    The example uses the `pingone_admin_environment_id` variable that can be mapped directly, or can be found from the environment name from the `pingone_environment`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/data-sources/environment" target="_blank">:octicons-link-external-16:</a> data source.

!!! note "Variable Mapping"
    The example uses the `license_id` variable that can be mapped directly, or can be found from the license name from the `pingone_licenses`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/data-sources/licenses" target="_blank">:octicons-link-external-16:</a> data source.

First, we will create the group in PingOne that we will assign our administrator users to.  This uses the `pingone_group`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/group" target="_blank">:octicons-link-external-16:</a> resource.
``` terraform
resource "pingone_group" "my_awesome_admins_group" {
  environment_id = var.pingone_admin_environment_id

  name        = "My awesome admins group"
  description = "My new awesome group for admins who are awesome"

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}
```

We then fetch the required roles using the `pingidentity/utils/pingone`<a href="https://registry.terraform.io/modules/pingidentity/utils/pingone/latest" target="_blank">:octicons-link-external-16:</a> helper module, so we can use role IDs in role assignment to the group:
``` terraform
module "admin_utils" {
  source  = "pingidentity/utils/pingone"
  version = "0.0.8"
  
  region         = "EU" // Will be either NA, EU, CA or AP depending on your tenant region.
  environment_id = var.pingone_admin_environment_id
}
```

We can then define the new sandbox environment using the [PingOne Terraform provider](https://pingidentity.github.io/terraform-docs/getting-started/pingone/) with the `pingone_environment`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/environment" target="_blank">:octicons-link-external-16:</a> resource, with the SSO service enabled.  This is the environment we want scope the administrator roles to, so our users can manage configuration and data within this environment:
``` terraform
resource "pingone_environment" "my_environment" {
  name        = "Example PingOne Role Permission Assignment Environment"
  type        = "SANDBOX"
  license_id  = var.license_id

  service {
    type = "SSO"
  }
}
```

Once the new environment has been created, lastly we can assign the roles to the administration users with the `pingone_group_role_assignment`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/group_role_assignment" target="_blank">:octicons-link-external-16:</a> resource.
``` terraform
resource "pingone_group_role_assignment" "admin_sso_identity_admin" {
  environment_id = var.pingone_admin_environment_id
  group_id       = pingone_group.my_awesome_admins_group.id
  role_id        = module.admin_utils.pingone_role_id_identity_data_admin

  scope_environment_id = pingone_environment.my_environment.id
}

resource "pingone_group_role_assignment" "admin_sso_environment_admin" {
  environment_id = var.pingone_admin_environment_id
  group_id       = pingone_group.my_awesome_admins_group.id
  role_id        = module.admin_utils.pingone_role_id_environment_admin

  scope_environment_id = pingone_environment.my_environment.id
}
```

*Full Runnable Example TBC*