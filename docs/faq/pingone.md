# Frequently Asked Questions - PingOne

## I've created a new environment with Terraform, but my admins can't see it

Check the admin user's role permissions.  The admin user will need any of the following roles to see it in the list of environments:

* **Organization Admin**
* **Environment Admin**
* **Identity Data Admin**
* **Client Application Developer**
* **Identity Data Read Only**
* **Configuration Read Only**

Some roles can be scoped to individual environments, including the **Environment Admin** role:

* If the admin user has the **Environment Admin** role scoped to the organization, the admin user will automatically inherit this permission for new environments.
* If the admin user has the **Environment Admin** role scoped to individual environments, the admin user will need the environment permission assigned after the environment has been created.

!!! warning "Role grant restrictions"
    Admins cannot grant roles that they haven't already been granted themselves.  This can mean that admins cannot grant the appropriate role themselves, but would need to be granted through Terraform, or by another admin that has the equivalent role, or that has the **Environment Admin** role scoped to the entire organization.

!!! note "Assigning Environment Permissions with Terraform"
    Admin permissions can be assigned using Terraform after environment creation.  See [PingOne Role Permission Assignment](../../examples/pingone/role-assignment.md) for an example of assigning roles using the PingOne Terraform provider.

!!! note "Read more about PingOne Roles"
    More information about role permissions can be found at the [PingOne Cloud Platform online documentation](https://docs.pingidentity.com/r/en-us/pingone/p1_c_roles)

## I've created a new environment (or population) with Terraform, but my admins can't view users, or manage group/population based configuration

Check the admin user's role permissions.  The admin user will need any of the following roles to be able to view and manage identity data and configuration:

* **Identity Data Admin**
* **Identity Data Read Only**

These roles are scoped to individual environments.  The admin user will need the environment level permission assigned after the new environment has been created.

!!! warning "Role grant restrictions"
    Admins cannot grant roles that they haven't already been granted themselves.  This can mean that admins cannot grant the appropriate role themselves, but would need to be granted through Terraform, or by another admin that has the equivalent role.

!!! note "Assigning Environment Permissions with Terraform"
    Admin permissions can be assigned using Terraform after environment creation.  See [PingOne Role Permission Assignment](../../examples/pingone/role-assignment.md) for an example of assigning roles using the PingOne Terraform provider.

These roles may be scoped by environment, but can also be scoped to individual populations of users.  With **Identity Data Admin** as an example:

* If the admin user has the **Identity Data Admin** role scoped to the environment, the admin user will automatically inherit this permission for new populations in the environment.
* If the admin user has the **Identity Data Admin** role scoped to individual populations, the admin user will need the population level permission assigned after the population has been created.

!!! note "Read more about PingOne Roles"
    More information about role permissions can be found at the [PingOne Cloud Platform online documentation](https://docs.pingidentity.com/r/en-us/pingone/p1_c_roles)