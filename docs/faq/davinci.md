# Frequently Asked Questions - DaVinci

## When I create a DaVinci connection using `davinci_connection`, how do I know what connector ID and field set to use?

The full set of connection definitions have been published on the Terraform Registry, in the `davinci_connection`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/connection#davinci-connection-definitions" target="_blank">:octicons-link-external-16:</a> resource documentation.

## I've published my flows with Terraform, but I can't see them in the DaVinci admin console

Where the Terraform provider has successfully applied changes that include one or more DaVinci flows, follow the below steps:

1. Check the value for the `environment_id`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow#environment_id" target="_blank">:octicons-link-external-16:</a> parameter in the `davinci_flow`<a href="https://registry.terraform.io/providers/pingidentity/davinci/latest/docs/resources/flow" target="_blank">:octicons-link-external-16:</a> resource is the correct value, to ensure that that the flows are being configured against the correct environment.
2. In the DaVinci console, check that the environment selector in the top left is set to the correct target environment.

!!! note "The environment isn't listed in the DaVinci admin console"
    If the environment selector list doesn't contain the target environment, check the admin user's role permissions.  See [I've enabled DaVinci on my environment with Terraform, but the environment isn't listed in the DaVinci admin console](#ive-enabled-davinci-on-my-environment-with-terraform-but-the-environment-isnt-listed-in-the-davinci-admin-console) below.

3. If flows are still not visible after checking the environment selection, refresh the DaVinci admin console to ensure that the latest configuration changes are picked up in the UI.

## I've enabled DaVinci on my environment with Terraform, but the environment isn't listed in the DaVinci admin console

Check the admin user's role permissions.  The admin user will need any of the following roles to see it in the list of environments in both the PingOne and DaVinci admin consoles:

* **DaVinci Admin**
* **DaVinci Admin Read Only**

!!! warning "Role grant restrictions"
    Admins cannot grant roles that they haven't already been granted themselves.  This can mean that admins may not be able to grant the appropriate role themselves, but would need to be granted through Terraform, or by another admin that has the equivalent role.

!!! note "Assigning Environment Permissions with Terraform"
    Admin permissions can be assigned using Terraform after environment creation.  See [PingOne Role Permission Assignment](../../examples/pingone/role-assignment/) for an example of assigning roles using the PingOne Terraform provider.

!!! note "Read more about PingOne Roles"
    More information about role permissions can be found at the [PingOne Cloud Platform online documentation](https://docs.pingidentity.com/r/en-us/pingone/p1_c_roles)

## I've previously used the "Environment Admin" and "Identity Data Admin" roles to manage DaVinci, but this combination no longer works / I cannot manage DaVinci configuration on creation of new environments

As of 15th August 2023, the existing role combination of **Environment Admin** and **Identity Data Admin** to manage DaVinci configuration was replaced with the **DaVinci Admin** role.

Role assignments should be reviewed from the perspective of [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege#), where:

1. Role assignments in scripts are changed so they no longer grant **Environment Admin** and **Identity Data Admin** for DaVinci admin access, but grant just the **DaVinci Admin** role instead.
2. Admin users that previously had the **Environment Admin** and **Identity Data Admin** role combination have now also been granted **DaVinci Admin**.  These admin user's role assignments should be reviewed such that:
    1. **Environment Admin** and **Identity Data Admin** are revoked if they provide too much administrative access to the wider PingOne tenant
    2. **DaVinci Admin** is revoked if it is not relevant to the admin user's function

!!! note "Read more about PingOne Roles"
    More information about role permissions can be found at the [PingOne Cloud Platform online documentation](https://docs.pingidentity.com/r/en-us/pingone/p1_c_roles)