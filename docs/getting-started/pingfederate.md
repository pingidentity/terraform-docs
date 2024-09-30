# Getting Started - PingFederate

<div class="banner" onclick="window.open('https://registry.terraform.io/providers/pingidentity/pingfederate/latest','');">
    <img class="assets" src="../../img/logos/tf-logo.svg" alt="Terraform logo" />
    <span class="caption">
        <a class="assetlinks" href="https://registry.terraform.io/providers/pingidentity/pingfederate/latest" target=”_blank”>Registry</a>
    </span>
</div>

## Requirements

* Terraform CLI 1.4+
* A running PingFederate server accessible over HTTPS, or Docker CLI to start one
* If using Docker to start a PingFederate server, a DevOps license is required - [Register for the DevOps program here](https://devops.pingidentity.com/how-to/devopsRegistration/)

## (Optional) Start a PingFederate Docker image to be configured

!!! warning "Using an Existing PingFederate Server"
    If you already have a running PingFederate server that you can reach over HTTPS, you can skip this step. The provider can be used with any PingFederate server.

First, start a PingFederate server using Docker. Your DevOps credentials will be read from the `${HOME}/.pingidentity/config` file. The HTTPS port (default `9999`) must be exposed.  This example starts the product with the `getting-started/pingfederate` server profile, running the latest version of PingFederate from Docker Hub.

```shell
docker run --name pingfederate_terraform_provider_container \
  -d -p 9031:9031 \
  -d -p 9999:9999 \
  --env-file "${HOME}/.pingidentity/config" \
  -e SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
  -e SERVER_PROFILE_PATH=getting-started/pingfederate
  pingidentity/pingfederate:latest
```

After starting the container, follow the logs until the server becomes available.

```shell
docker logs -f pingfederate_terraform_provider_container
```

After you see the following message in the container logs, the server is ready to receive requests from the provider:

```shell
PingFederate is up
```

## Accessing the PingFederate API

Gaining access to the API depends on where your PingFederate instance is running.  In order to work with the API, you need to authenticate just as you would for performing administrative tasks.  To interact directly with the API in the browser and view the documentation, typically you would browse to the following URL:

`https://<pf_host>:9999/pf-admin-api/api-docs/`

where **<pf_host\>** is the network address of your PingFederate server. This target can be an IP address, a host name, or a fully qualified domain name. It must be reachable from your computer.

If using OIDC, see the [OIDC Authentication](https://docs.pingidentity.com/r/en-us/pingfederate-110/pf_enabling_oidc_based_auth) page for more information on how to connect.

When using a local container as shown above, the port mappings result in PingFederate being available at `https://localhost:9999/pingfederate/app#/` by default.  The provider supports an attribute `admin_api_path` which defaults to **/pf-admin-api/v1**.  If your environment has a load balancer or other network configuration that requires a different path to the API, you can configure the provider to use it.

The PingFederate Terraform provider applies configuration at the API endpoints using the specified port (`9999`) over HTTPS when accessing the product locally under Docker.

## Determine credentials that are able to configure the server

The provider supports basic authentication, OAuth2 client credentials flow authentication, and access token authentication for connection to the configuration API. In this example, basic authentication will be used.

When using basic authentication, the provider will need the `username` and `password` of a user with permission to manage server configuration. In the PingFederate Docker image, the administrative user defaults to the username `administrator` with password `2FederateM0re`.

When using OAuth2 client credentials, the `client_id`, `client_secret`, and `token_url` attributes are required in the provider configuration, with `scopes` being optional.

When using an access token, only `access_token` is required in the provider configuration.

For examples of configuring other authentication methods, see the [registry documentation](https://registry.terraform.io/providers/pingidentity/pingfederate/latest/docs).

## Determine what version of PingFederate you are running

The provider requires that the version of PingFederate is specified.  

You can do this one of two ways:

* Using the `product_version` attribute when configuring the provider:

```shell
provider "pingfederate" {
  ...
  product_version = "12.1"
}
```

* Setting the `PINGFEDERATE_PROVIDER_PRODUCT_VERSION` environment variable to the version of PingFederate you are running:

```shell
export PINGFEDERATE_PROVIDER_PRODUCT_VERSION=12.1
```

If using the container, you can view the product version using by running a shell in the container and searching for the appropriate environment variable:

```shell
docker container exec -it pingfederate_terraform_provider_container /bin/sh

# In the container shell, get the version
env | grep PING_PRODUCT_VERSION
```

!!! note "Precedence"
    The `product_version` attribute takes precedence over the `PINGFEDERATE_PROVIDER_PRODUCT_VERSION` environment variable.

If neither is set, the provider will throw an error.

## Trusting PingFederate certificates

PingFederate generates a self-signed certificate by default, which is presented by the server when connecting.
The default self-signed certificate can also be replaced with a custom certificate. The provider has a few ways of configuring trust for the HTTPS connection with the server.

By default, the provider will trust the host's default root CA set when connecting to the server.

If you need to provide CA certificates for the provider to trust, you can use the `ca_certificate_pem_files` attribute. This attribute supports providing a set of paths to files containing PEM-encoded CA certificates to be trusted.

The `PINGFEDERATE_PROVIDER_CA_CERTIFICATE_PEM_FILES` environment variable can also be used, with commas to delimit multiple PEM file paths if necessary.

Finally, the provider supports an `insecure_trust_all_tls` boolean attribute that enables it to trust all certificates when connecting to the server.

!!! warning "Insecure Trust All TLS"
    The `insecure_trust_all_tls` flag, when set to `true`, is insecure and is intended for development and testing only.  You should not enable this option for production use.

## Use the provider to configure PingFederate

You are now ready to configure the PingFederate server using the provider.  For example:

```shell
terraform {
  required_version = ">=1.4"
  required_providers {
    pingfederate = {
      version = ">= 1.0, < 2.0"
      source = "pingidentity/pingfederate"
    }
  }
}

provider "pingfederate" {
  # Credentials in this example are the default credentials for the PingFederate Docker image
  # This method is insecure and credentials should not be stored in this file in production
  username = "administrator"
  password = "2FederateM0re"
  https_host = "https://localhost:9999"
  admin_api_path = "/pf-admin-api/v1"
  # Warning: 'insecure_trust_all_tls' configures the provider to trust any certificate
  # presented by the PingFederate server.
  insecure_trust_all_tls = true
  product_version = "12.1"
}

# Update the default global contact information
resource "pingfederate_server_settings" "serverSettingsExample" {
  contact_info = {
    company    = "Example Company"
    email      = "adminemail@company.example"
    first_name = "Jane"
    last_name  = "Admin"
    phone      = "555-555-1222"
  }
}

# Update general server settings
resource "pingfederate_server_settings_general" "serverSettingsGeneralExample" {
  datastore_validation_interval_secs          = 300
  disable_automatic_connection_validation     = false
  idp_connection_transaction_logging_override = "NONE"
  request_header_for_correlation_id           = "example"
  sp_connection_transaction_logging_override  = "FULL"
}
```
