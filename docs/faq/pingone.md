# Frequently Asked Questions - PingOne

## I can't create a workforce enabled environment / where can I Terraform creation of a PingID enabled environment?

The PingOne provider does not yet support creation of a PingID enabled workforce environment.  You may track the list of known issues and provider limitations [on the project's Github](https://github.com/pingidentity/terraform-provider-pingone/issues/451).

## I've created a new environment with Terraform, but my admins can't see it

Check the admin user's role permissions.  The admin user will need any of the following roles to see it in the list of environments:

* **Organization Admin**
* **Environment Admin**
* **Identity Data Admin**
* **Client Application Developer**
* **Identity Data Read Only**
* **Configuration Read Only**

Please see the [Admin Role Management Considerations](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/guides/admin-role-management) guide on the provider's registry documentation for details on role assignment and considerations for admin role management when using Terraform.

## I've created a new environment (or population) with Terraform, but my admins can't view users, or manage group/population based configuration

Check the admin user's role permissions.  The admin user will need any of the following roles to be able to view and manage identity data and configuration:

* **Identity Data Admin**
* **Identity Data Read Only**

Please see the [Admin Role Management Considerations](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/guides/admin-role-management) guide on the provider's registry documentation for details on role assignment and considerations for admin role management when using Terraform.

## I get an error "Actor does not have permissions to access worker application client secrets"

Admin actors (users, worker applications, connections) may not be able to view or rotate a worker application's secret when they previously have been able to as an unexpected change of behaviour.

The change in ability to manage a worker application's client secret typically occurs when the worker application is granted additional role permissions that the user, admin worker application or connection doesn't have. In effect, it means the worker application whose secret cannot be managed has a higher level of privilege to manage configuration and data within the tenant. The ability to view and change the secret is therefore restricted to mitigate privilege escalation issues where admin actors could potentially use the higher privileged worker application to make changes they are not authorised to make in the platform.

For more information, and guidance on how to resolve this error, see the [Admin Role Management Considerations - When Admins Cannot View or Manage a Worker Application Secret](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs/guides/admin-role-management#when-admins-cannot-view-or-manage-a-worker-application-secret) guide on the provider's registry documentation.
