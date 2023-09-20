# Setting up SSO to PingDirectory from PingOne

Reference: [Setting up SSO to PingDirectory from PingOne](https://docs.pingidentity.com/r/en-us/pingone/pd_ds_set_up_sso_pingdir_pingone)

## Before you begin

* A PingDirectory server configured for Terraform access. This server will host the admin console that is being configured for SSO.  For more information, see [Getting Started - PingDirectory](https://terraform.pingidentity.com/getting-started/pingdirectory/)
* A PingOne account configured for Terraform access.  For more information, see [Getting Started - PingOne](https://terraform.pingidentity.com/getting-started/pingone/)

## Setting Connection Details
The following environment variables should be set prior to running the example.  For more information, see the registry documentation for each provider.

| Variable name                                   | Schema Documentation                                                                                                                            | Required/Optional |
|-------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|
| `PINGDIRECTORY_PROVIDER_USERNAME`               | [PingDirectory - username](https://registry.terraform.io/providers/pingidentity/pingdirectory/latest/docs#username)                             | Required          |
| `PINGDIRECTORY_PROVIDER_PASSWORD`               | [PingDirectory - password](https://registry.terraform.io/providers/pingidentity/pingdirectory/latest/docs#password)                             | Required          |
| `PINGDIRECTORY_PROVIDER_HTTPS_HOST`             | [PingDirectory - http_host](https://registry.terraform.io/providers/pingidentity/pingdirectory/latest/docs#https_host)                          | Required          |
| `PINGDIRECTORY_PROVIDER_INSECURE_TRUST_ALL_TLS` | [PingDirectory - insecure_trust_all_tls](https://registry.terraform.io/providers/pingidentity/pingdirectory/latest/docs#insecure_trust_all_tls) | Optional          |
| `PINGONE_CLIENT_ID`                             | [PingOne - client_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_id)                                       | Required          |
| `PINGONE_CLIENT_SECRET`                         | [PingOne - client_secret](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_secret)                               | Required          |
| `PINGONE_ENVIRONMENT_ID`                        | [PingOne - environment_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#environment_id)                             | Required          |
| `PINGONE_REGION`                                | [PingOne - region](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#region)                                             | Required          |


## Setting Variables
The following variables can be set prior to running the example:

| Variable name                        | Required | Data Type | Default Value | Example Value                      | Description                                                                                                                                 |
|--------------------------------------|----------|-----------|---------------|------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `pingdirectory_console_base_url` | No       | String    | `https://localhost:8443` | `https://my-directory-host:8443` | The PingDirectory Console's base URL, used when forming the console sign-on link and the OpenID Connect callback URL |
| `pingdirectory_ldap_host`        | No       | String    | *no default*             | `my-directory-host` | The LDAP hostname of the PingDirectory server.  If set, this is appended to the PingDirectory Console link as the default server to manage. |
| `pingdirectory_ldaps_port`        | No       | Number    | *no default*             | `6636` | The LDAPS port of the PingDirectory server.  If set, this is appended to the PingDirectory Console link as the default server to manage. |
| `pingone_environment_license_id`     | Yes      | String    | *no default*  |                                    | A valid license UUID to apply to the new environment. See [Finding Required IDs](https://terraform.pingidentity.com/getting-started/pingone/#license-id-organization-id-and-organization-name) for instructions on how to retrieve the `pingone_environment_license_id` value from the PingOne console. |
| `pingone_environment_name`           | No       | String    | `Terraform Example - Setting up SSO to PingDirectory from PingOne` | `My Environment` | A string that represents the name of the PingOne customer environment to create and manage with Terraform. |
| `append_date_to_environment_name`    | No       | Boolean   | `true`  | `true`                             | A boolean that determines whether to append the current date to the pingone_environment_name value.                                         |

## Outputs
The following outputs are returned from the example:

| Variable name                                             | Data Type | Sensitive Value | Description                                                                                                      |
|-----------------------------------------------------------|-----------|-----------------|------------------------------------------------------------------------------------------------------------------|
| `pingone_environment_name`          | String    | No             | The environment name created by the example          |

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
