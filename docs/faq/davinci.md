# Frequently Asked Questions - DaVinci

## I've published my flows with Terraform, but I can't see them in the DaVinci admin console

Where the Terraform provider has successfully applied changes that include one or more DaVinci flows, follow the below steps:

1. Check the value for the `environment_id`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow#environment_id" target="_blank">:octicons-link-external-16:</a> parameter in the `davinci_flow`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow" target="_blank">:octicons-link-external-16:</a> resource is the correct value, to ensure that that the flows are being configured against the correct environment.
2. Refresh the DaVinci admin console to ensure that the latest configuration changes are picked up in the UI.
3. Check the admin user's role permissions.  See [I've enabled DaVinci on my environment with Terraform, but the environment isn't listed in the DaVinci admin console](#ive-enabled-davinci-on-my-environment-with-terraform-but-the-environment-isnt-listed-in-the-davinci-admin-console) below.

## I've enabled DaVinci on my environment with Terraform, but the environment isn't listed in the DaVinci admin console

Check the admin user's role permissions.  The admin user will need any of the following roles to see it in the list of environments in both the PingOne and DaVinci admin consoles:

* **Environment Admin**
* **Identity Data Admin**

The **Identity Data Admin** role is scoped to individual environments, and optionally individual populations within environments.  If the environment has been newly created, then the admin users will need to have the **Identity Data Admin** role assigned.

!!! warning "Role grant restrictions"
    Admins cannot grant roles that they haven't already been granted themselves.  This can mean that admins cannot grant the appropriate role themselves, but would need to be granted through Terraform, or by another admin that has the equivalent role.

!!! note "Assigning Environment Permissions with Terraform"
    Admin permissions can be assigned using Terraform after environment creation.  See [PingOne Role Permission Assignment](../../examples/pingone/role-assignment.md) for an example of assigning roles using the PingOne Terraform provider.

!!! note "Read more about PingOne Roles"
    More information about role permissions can be found at the [PingOne Cloud Platform online documentation](https://docs.pingidentity.com/r/en-us/pingone/p1_c_roles)
