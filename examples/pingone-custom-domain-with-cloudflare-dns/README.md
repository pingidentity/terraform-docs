# PingOne Custom Domain with Cloudflare DNS

The following example:
1. Creates a demo PingOne environment named **Terraform Example - Custom Domain with Cloudflare DNS**.
2. Sets a custom domain based on variable values.
3. Creates a CNAME verification entry with Cloudflare DNS.
4. Proceeds to verify the custom domain on PingOne.
5. Installs a user provided CA signed TLS certificate, the certificate chain and private key to the custom domain.

Once complete, the end-user facing HTTP endpoints will be fully configured for your custom domain.

## Before you begin

* A cloudflare account for Terraform access.  For more information, see the [Cloudflare Terraform Provider documentation](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs).
* A PingOne account configured for Terraform access.  For more information, see [Getting Started - PingOne](https://terraform.pingidentity.com/getting-started/pingone/)
* A CA signed SSL certifcate and key for the custom domain.  The certificate must not be expired, must not be self signed and the domain must match one of the subject alternative name (SAN) values on the certificate.  If you do not have a CA signed SSL certificate to hand you can use the [LetsEncrypt](https://letsencrypt.org/getting-started/) service and the [Certbot](https://certbot.eff.org/) tool.

## Setting Connection Details
The following environment variables should be set prior to running the example.  For more information, see the registry documentation for each provider.

| Variable name                                   | Schema Documentation                                                                                                | Required/Optional |
|-------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|-------------------|
| `CLOUDFLARE_API_TOKEN`                          | [Cloudflare - api_token](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs#api_token)       | Required          |
| `PINGONE_CLIENT_ID`                             | [PingOne - client_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_id)           | Required          |
| `PINGONE_CLIENT_SECRET`                         | [PingOne - client_secret](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#client_secret)   | Required          |
| `PINGONE_ENVIRONMENT_ID`                        | [PingOne - environment_id](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#environment_id) | Required          |
| `PINGONE_REGION`                                | [PingOne - region](https://registry.terraform.io/providers/pingidentity/pingone/latest/docs#region)                 | Required          |


## Setting Variables
The following variables can be set prior to running the example:

| Variable name                        | Required | Data Type | Default Value | Example Value                      | Description                                                                                                                                 |
|--------------------------------------|----------|-----------|---------------|------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `pingone_environment_license_id`                 | Yes      | String    | *no default*  |                                    | A valid license UUID to apply to the new environment. See [Finding Required IDs](https://terraform.pingidentity.com/getting-started/pingone/#license-id-organization-id-and-organization-name) for instructions on how to retrieve the `pingone_environment_license_id` value from the PingOne console. |
| `cloudflare_domain_zone`             | Yes      | String    | *no default*  | `example.com`                      | The domain zone to be configured in the Cloudflare account.                                                                                 |
| `custom_domain_cname`                | Yes      | String    | *no default*  | `auth`                             | The CNAME to configure in PingOne and Cloudflare.  This is prefixed to the domain zone value to create the full domain, `auth.example.com`. |
| `certificate_pem_file`               | Yes      | String    | *no default*  | `-----BEGIN CERTIFICATE-----\n...` | A valid PEM encoded public certificate to apply for the custom domain in the PingOne environment.                                           |
| `intermediate_certificates_pem_file` | Yes      | String    | *no default*  | `-----BEGIN CERTIFICATE-----\n...` | A valid PEM encoded concatenated CA and intermediate certificates that form the chain of trust for the `certificate_pem_file`.              |
| `private_key_pem_file`               | Yes      | String    | *no default*  | `-----BEGIN PRIVATE KEY-----\n...` | A valid PEM encoded private key to apply to the PingOne environment, to initiate TLS on the custom domain.                                  |
| `pingone_environment_name`           | No       | String    | `Terraform Example - Custom Domain with Cloudflare DNS` | `My Environment` | A string that represents the name of the PingOne customer environment to create and manage with Terraform. |
| `append_date_to_environment_name`    | No       | Boolean   | `true`  | `true`                             | A boolean that determines whether to append the current date to the pingone_environment_name value.

## Outputs
The following outputs are returned from the example:

| Variable name                                             | Data Type | Sensitive Value | Description                                                                                                      |
|-----------------------------------------------------------|-----------|-----------------|------------------------------------------------------------------------------------------------------------------|
| `pingone_self_service_endpoint`      | String    | No              | The PingOne self-service endpoint for the environment.  The PingOne Self-Service application will use the custom domain if configured correctly.                |
| `pingone_oidc_well_known_endpoint`              | String    | No              | The PingOne OIDC well-known endpoint for the environment.  This endpoint will use the custom domain if configured correctly.              |
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
