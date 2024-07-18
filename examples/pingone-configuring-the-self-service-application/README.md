# Configure the PingOne Self-Service Application

The following example:
1. Creates a demo PingOne environment named **Terraform Example - Configuring the Self-Service Application**.
2. Sets branding settings to the PingOne Self-Service application.
3. Applies resource grants that enable/disable features within the Self-Service application.

## Before you begin

* A PingOne account configured for Terraform access.  For more information, see [Getting Started - PingOne](https://terraform.pingidentity.com/getting-started/pingone/)

## Setting Connection Details
The following environment variables should be set prior to running the example.  For more information, see the registry documentation for each provider.

| Variable name                                   | Schema Documentation                                                                                                | Required/Optional |
|-------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|-------------------|
| `PINGONE_CLIENT_ID`                             | [PingOne - client_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_id)           | Required          |
| `PINGONE_CLIENT_SECRET`                         | [PingOne - client_secret](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_secret)   | Required          |
| `PINGONE_ENVIRONMENT_ID`                        | [PingOne - environment_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#environment_id) | Required          |
| `PINGONE_REGION_CODE`                           | [PingOne - region_code](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#region_code)                 | Required          |


## Setting Variables
The following variables can be set prior to running the example:

| Variable name                        | Required | Data Type | Default Value | Example Value                      | Description                                                                                                                                 |
|--------------------------------------|----------|-----------|---------------|------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `pingone_environment_license_id`     | Yes      | String    | *no default*  |                                    | A valid license UUID to apply to the new environment.                                                                                       |
| `pingone_environment_name`           | No       | String    | `Terraform Example - Configuring the Self-Service Application`  | `My new environment` | A string that represents the name of the PingOne customer environment to create and manage with Terraform. |
| `append_date_to_environment_name`    | No       | String    | `true`        | `true`                             | A boolean that determines whether to append the current date to the pingone_environment_name value.                                         |

See [Finding Required IDs](https://terraform.pingidentity.com/getting-started/pingone/#license-id-organization-id-and-organization-name) for instructions on how to retrieve the `pingone_environment_license_id` value from the PingOne console.

## Running the Example
Use the following to run the example:

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
