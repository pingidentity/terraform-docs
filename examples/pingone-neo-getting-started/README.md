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
| `pingone_license_id`                 | Yes      | String    | *no default*  |                                    | A valid license UUID to apply to the new environment.                                              |



See [Finding Required IDs](https://terraform.pingidentity.com/getting-started/pingone/#license-id-organization-id-and-organization-name) for instructions on how to retrieve the `pingone_license_id` value from the PingOne console.

## Running the Example
Use the following to run the example:

```shell
terraform plan -out infra.tfout
```

```shell
terraform apply "infra.tfout"
```