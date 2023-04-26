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

| Variable name                    | Required | Data Type | Default Value            |
|----------------------------------|----------|-----------|--------------------------|
| `pingdirectory_console_base_url` | No       | String    | `https://localhost:8443` |
| `pingdirectory_ldap_host`        | No       | String    | *no default*             |
| `pingdirectory_ldap_port`        | No       | Number    | *no default*             |

## Running the Example
Use the following to run the example:

```shell
terraform plan -out infra.tfout
```

```shell
terraform apply "infra.tfout"
```