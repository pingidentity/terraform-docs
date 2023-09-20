# Configuring PingOne Neo
The following example:
1. Creates a demo PingOne environment named **Terraform Example - Getting Started with PingOne Neo**.
2. Configures two PingOne Verify policy examples.
3. Configures an example Digital Wallet application.
4. Configures a PingOne Credentials verifiable credential using a group-based issuance rule.
5. Configures a PingOne Credentials verifiable credential using a population-based issuance rule.

## Before you begin
You must have:

* A PingOne account configured for Terraform access.  For more information, see [Getting Started - PingOne](https://terraform.pingidentity.com/getting-started/pingone/)

For additional information, including demonstration flows and how to obtain the sample wallet, refer to the [PingOne Neo Playground](https://www.neoidentity.com/playground)

## Setting Connection Details
The following environment variables should be set prior to running the example.  For more information, see the registry documentation for each provider.

| Variable name                                   | Schema Documentation                                                                                                                            | Required/Optional |
|-------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|
| `PINGONE_CLIENT_ID`                             | [PingOne - client_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_id)                                       | Required          |
| `PINGONE_CLIENT_SECRET`                         | [PingOne - client_secret](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_secret)                               | Required          |
| `PINGONE_ENVIRONMENT_ID`                        | [PingOne - environment_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#environment_id)                             | Required          |
| `PINGONE_REGION`                                | [PingOne - region](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#region)                                             | Required          |


## Setting Variables
The following variables can be set prior to running the example:

| Variable name                        | Required | Data Type | Default Value | Example Value                      | Description                                                                                        |
|--------------------------------------|----------|-----------|---------------|------------------------------------|----------------------------------------------------------------------------------------------------|
| `pingone_environment_license_id`     | Yes      | String    | *no default*  |                                    | A valid license UUID to apply to the new environment. See [Finding Required IDs](https://terraform.pingidentity.com/getting-started/pingone/#license-id-organization-id-and-organization-name) for instructions on how to retrieve the `pingone_license_id` value from the PingOne console. |
| `pingone_environment_name`           | No       | String    | `Terraform Example - Getting Started with PingOne Neo` | `My Environment` | A string that represents the name of the PingOne customer environment to create and manage with Terraform. |
| `append_date_to_environment_name`    | No       | Boolean   | `true`  | `true`                             | A boolean that determines whether to append the current date to the pingone_environment_name value.


## Outputs
The following outputs are returned from the example:

| Variable name                                             | Data Type | Sensitive Value | Description                                                                                                      |
|-----------------------------------------------------------|-----------|-----------------|------------------------------------------------------------------------------------------------------------------|
| `pingone_environment_name`          | String    | No             | The environment name created by the example          |


## Enable Administrator Access
An existing admin user will need the following roles to be able to view and manage PingOne Credentials:

* **Environment Admin**
* **Identity Data Admin**

These roles are scoped to individual environments.  The admin user will need the environment level permission assigned after the new environment has been created.

!!! warning "Role grant restrictions"
    Admins cannot grant roles that they haven't already been granted themselves.  This can mean that admins cannot grant the appropriate role themselves, but would need to be granted through Terraform, or by another admin that has the equivalent role.

!!! note "Assigning Environment Permissions with Terraform"
    Admin permissions can be assigned using Terraform after environment creation.  See [PingOne Role Permission Assignment](../../examples/pingone/role-assignment/) for an example of assigning roles using the PingOne Terraform provider.

## Running the Example
Use the following to run the example:

```shell
terraform init
```

```shell
terraform plan -out infra.tfout
```

```shell
terraform apply "infra.tfout"
```

## Clean up resources
Use the following to clean up the environment:

```shell
terraform destroy
```
