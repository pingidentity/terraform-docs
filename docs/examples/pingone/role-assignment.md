# PingOne Role Permission Assignment

The following shows an example of environment creation using the PingOne Terraform provider, followed by role permission assignment to administration users belonging to the example "My Administrators" population.  The example assumes that all relevant admins users will have a role strategy as follows:

* **Environment Admin**, scoped to individual environments (not scoped to the organization)
* **Identity Data Admin**, scoped to individual environments

!!! note "Variable Mapping"
    The example uses the `pingone_admin_environment_id` variable that can be mapped directly, or can be found from the environment name from the `pingone_environment`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/data-sources/environment" target="_blank">:octicons-link-external-16:</a> data source.

!!! note "Variable Mapping"
    The example uses the `license_id` variable that can be mapped directly, or can be found from the license name from the `pingone_licenses`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/data-sources/licenses" target="_blank">:octicons-link-external-16:</a> data source.

First, we will need the ID of the "My Administrators" population, which we can look up from the `pingone_population`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/data-sources/population" target="_blank">:octicons-link-external-16:</a> data source.
``` terraform
data "pingone_population" "administrators_population" {
  environment_id = var.pingone_admin_environment_id

  name = "My Administrators"
}
```

We then fetch the administration users using the `pingone_users`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/data-sources/users" target="_blank">:octicons-link-external-16:</a> data source, so we can use their IDs in role assignment.
``` terraform
data "pingone_users" "admin_users" {
  environment_id = var.pingone_admin_environment_id

  data_filter {
    name = "population.id"
    values = [
      pingone_population.administrators_population.id
    ]
  }
}
```

We then fetch the required roles using the `pingone_role`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/data-sources/role" target="_blank">:octicons-link-external-16:</a> data source, so we can use their IDs in role assignment:
``` terraform
data "pingone_role" "environment_admin" {
  name = "Environment Admin"
}

data "pingone_role" "identity_data_admin" {
  name = "Identity Data Admin"
}
```

We can then define the new environment with the [PingOne Terraform provider](https://pingidentity.github.io/terraform-docs/getting-started/pingone/) with the `pingone_environment`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/environment" target="_blank">:octicons-link-external-16:</a> resource, with the SSO service enabled:

``` terraform
resource "pingone_environment" "my_environment" {
  name        = "Example PingOne Role Permission Assignment Environment"
  type        = "SANDBOX"
  license_id  = var.license_id

  default_population {}

  service {
    type = "SSO"
  }
}
```

Once the new environment has been created, lastly we can assign the roles to the administration users with the `pingone_role_assignment_user`<a href="https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/resources/role_assignment_user" target="_blank">:octicons-link-external-16:</a> resource.
``` terraform
resource "pingone_role_assignment_user" "admin_sso_identity_admin" {

  count = length(data.pingone_users.admin_users.ids)

  environment_id       = var.pingone_admin_environment_id
  user_id              = data.pingone_users.admin_users.ids[count.index]
  role_id              = data.pingone_role.identity_data_admin.id
  scope_environment_id = pingone_environment.my_environment.id
}

resource "pingone_role_assignment_user" "admin_sso_environment_admin" {

  count = length(data.pingone_users.admin_users.ids)

  environment_id       = var.pingone_admin_environment_id
  user_id              = data.pingone_users.admin_users.ids[count.index]
  role_id              = data.pingone_role.environment_admin.id
  scope_environment_id = pingone_environment.my_environment.id
}
```

*Full Runnable Example TBC*