# Using Postman's "OAuth 2.0" authorization type with PingOne

The following example:
1. Creates a demo PingOne environment named **Terraform Example - Postman OAuth 2.0 authorization type integration**.
2. Creates an application called "Postman" that is configured for use with Postman.

Once complete, the PingOne environment can be configured with Postman using the "OAuth 2.0" authorization type.

## Before you begin

* Download and install Postman.  For more information, see the [Postman website](https://www.postman.com/).
* Download and import Ping's Postman collections for PingOne.  For more information, see the [PingOne API Documentation](https://apidocs.pingidentity.com/pingone/main/v1/api/#download-the-pingone-postman-collections).
* A PingOne account configured for Terraform access.  For more information, see [Getting Started - PingOne](https://terraform.pingidentity.com/getting-started/pingone/)

## Setting Connection Details
The following environment variables should be set prior to running the example.  For more information, see the registry documentation for each provider.

| Variable name                                   | Schema Documentation                                                                                                | Required/Optional |
|-------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|-------------------|
| `PINGONE_CLIENT_ID`                             | [PingOne - client_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_id)           | Required          |
| `PINGONE_CLIENT_SECRET`                         | [PingOne - client_secret](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_secret)   | Required          |
| `PINGONE_ENVIRONMENT_ID`                        | [PingOne - environment_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#environment_id) | Required          |
| `PINGONE_REGION_CODE`                           | [PingOne - region_code](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#region_code)       | Required          |


## Setting Variables
The following variables can be set prior to running the example:

| Variable name                        | Required | Data Type | Default Value | Example Value                      | Description                                                                                                                                 |
|--------------------------------------|----------|-----------|---------------|------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `pingone_environment_license_id`     | Yes      | String    | *no default*  |                                    | A valid license UUID to apply to the new environment. See [Finding Required IDs](https://terraform.pingidentity.com/getting-started/pingone/#license-id-organization-id-and-organization-name) for instructions on how to retrieve the `pingone_environment_license_id` value from the PingOne console. |
| `pingone_environment_name`           | No       | String    | `Terraform Example - Postman OAuth 2.0 authorization type integration` | `My Environment` | A string that represents the name of the PingOne customer environment to create and manage with Terraform. |
| `append_date_to_environment_name`    | No       | Boolean   | `true`  | `true`                             | A boolean that determines whether to append the current date to the pingone_environment_name value.                                         |

## Outputs
The following outputs are returned from the example:

| Variable name                                             | Data Type | Sensitive Value | Description                                                                                                      |
|-----------------------------------------------------------|-----------|-----------------|------------------------------------------------------------------------------------------------------------------|
| `pingone_environment_name`          | String    | No             | The environment name created by the example          |
| `postman_application_client_id`      | String    | No              | The client ID used for the Postman OAuth 2.0 authorization type integration.  As the application is configured to use PKCE, the client secret is not required. |
| `postman_application_authorization_endpoint`              | String    | No              | The environment's authorization endpoint used for the Postman OAuth 2.0 authorization type integration. |
| `postman_application_token_endpoint`              | String    | No              | The environment's token endpoint used for the Postman OAuth 2.0 authorization type integration. |

## Running the Example
Use the following to run the Terraform example:

```shell
terraform init
```

```shell
terraform plan -out infra.tfout
```

```shell
terraform apply "infra.tfout"
```

## Postman Configuration

The table below states the values that must be configured in Postman for the integration to work. It is most effective when these settings are applied to the collection root, and each request in the collection has it's authorization set to "Inherit auth from parent".

| Postman Authorization Setting | Value                                                                                                                                                                                                            |
|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Type                          | `OAuth 2.0`                                                                                                                                                                                                      |
| Add auth data to              | `Request Headers`                                                                                                                                                                                                |
| **Current Token**             | |
| Token                         | Set to the token retrieved at the end of the configuration process                                                                                                                                               |
| Use Token Type                | `Access token`                                                                                                                                                                                                   |
| Header Prefix                 | `Bearer`                                                                                                                                                                                                         |
| Auto-refresh token            | Switch on                                                                                                                                                                                                        |
| Share token                   | Switch off                                                                                                                                                                                                       |
| **Configure New Token**       | |
| Token Name                    | `PingOne`                                                                                                                                                                                                        |
| Grant Type                    | `Authorization Code (With PKCE)`                                                                                                                                                                                 |
| Callback URL                  | Tick `Authorize using browser`                                                                                                                                                                                   |
| Auth URL                      | The "Authorization URL" from the application configured in PingOne, the result value for the `postman_application_authorization_endpoint` output of this example.                                                |
| Access Token URL              | The "Token Endpoint" from the application configured in PingOne, the result value for the `postman_application_token_endpoint` output of this example.                                                           |
| Client ID                     | The "Client ID" from the application configured in PingOne, the result value for the `postman_application_client_id` output of this example.                                                                     |
| Client Secret                 | *Intentionally left blank*                                                                                                                                                                                       |
| Code Challenge Method         | `SHA-256`                                                                                                                                                                                                        |
| Code Verifier                 | *Intentionally left blank*                                                                                                                                                                                       |
| Scope                         | `openid`                                                                                                                                                                                                         |
| State                         | *Intentionally left blank*                                                                                                                                                                                       |
| Client Authentication         | `Send client credentials in body`                                                                                                                                                                                |
| **Advanced**                  | |
| Refresh Token URL             | *Intentionally left blank*                                                                                                                                                                                       |
| Auth Request                  | *Intentionally left blank*                                                                                                                                                                                       |
| Token Request                 | *Intentionally left blank*                                                                                                                                                                                       |
| Refresh Request               | **Key**: `client_id`<br/>**Value**: The "Client ID" from the application configured in PingOne, the result value for the `postman_application_client_id` output of this example.<br/>**Send In**: `Request Body` |

## Test the Configuration

* Create a user with a password by following the [PingOne Documentation](https://docs.pingidentity.com/r/en-us/pingone/p1_t_adduser)
* In Postman, ensure that an API request is configured to use the "OAuth 2.0" authorization type and configure as shown above, following documentation on the [Postman website](https://learning.postman.com/docs/sending-requests/authorization/oauth-20/)
* Once configured in both Postman and PingOne, in the Postman authorization settings you can "Get New Access Token", and select "Use Token".

## Clean up resources
Use the following to clean up the environment:

```shell
terraform destroy
```
