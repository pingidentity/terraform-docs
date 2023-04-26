# Configuring PingOne for Windows Passwordless Login

Reference: [Setting up Windows passwordless login](https://docs.pingidentity.com/r/en-us/solution-guides/bp_setting_up_windows_passwordless_login)

## Before you begin

To set up and use the PingID integration for passwordless Windows login, the following system requirements must be met:

* Microsoft Active Directory is running on Windows Server 2016 or later
* Users' computers must be running Windows 10 (64-bit), and must support TPM 2.0.

You must have:

* Admin rights for the domain controller
* A PingOne account configured for Terraform access.  For more information, see [Getting Started - PingOne](https://terraform.pingidentity.com/getting-started/pingone/)
* A PingOne workforce environment configured with PingID.  Follow the steps described in [Creating a PingOne environment and connecting it to a PingID account](https://docs.pingidentity.com/r/en-us/solution-guides/czz1662494125032) and optionally [Configuring identity store provisioners](https://docs.pingidentity.com/r/en-us/solution-guides/dgp1662481986872) only.  This Terraform example performs the remaining PingOne configuration.

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

| Variable name              | Required | Data Type | Default Value |
|----------------------------|----------|-----------|---------------|
| `workforce_environment_id` | Yes      | String    | *no default*  |

## Outputs
The following outputs are returned from the example:

| Variable name                                             | Data Type | Sensitive Value | Description                                                                                                      |
|-----------------------------------------------------------|-----------|-----------------|------------------------------------------------------------------------------------------------------------------|
| `windows_login_passwordless_ca_certificate_pem_file`      | String    | No              | An export of the generated CA issuing certificate, in PEM format, to publish to Active Directory.                |
| `windows_login_passwordless_agent_client_id`              | String    | No              | The OIDC client ID to use when installing the Windows Login Passwordless Desktop Agent application.              |
| `windows_login_passwordless_agent_client_secret`          | String    | Yes             | The OIDC client secret to use when installing the Windows Login Passwordless Desktop Agent application.          |
| `windows_login_passwordless_agent_discovery_endpoint_url` | String    | No              | The OIDC Discovery Endpoint URL to use when installing the Windows Login Passwordless Desktop Agent application. |

## Running the Example
Use the following to run the example:

```shell
terraform plan -out infra.tfout
```

```shell
terraform apply "infra.tfout"
```