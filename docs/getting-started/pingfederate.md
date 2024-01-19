# Getting Started - PingFederate

<div class="banner" onclick="window.open('https://registry.terraform.io/providers/pingidentity/pingfederate/latest','');">
    <img class="assets" src="../../img/logos/tf-logo.svg" alt="Terraform logo" />
    <span class="caption">
        <a class="assetlinks" href="https://registry.terraform.io/providers/pingidentity/pingfederate/latest" target=”_blank”>Registry</a>
    </span>
</div>

## EARLY ACCESS

As of January 2024, the PingFederate Terraform provider is an early access release. **This status indicates that the provider is in active development and is subject to breaking changes. While available in the Terraform Registry, use of this provider is not recommended for production use at this time.**

## Requirements

* Terraform CLI 1.4+
* A running PingFederate server accessible over HTTPS, or Docker CLI to start one
* If using Docker to start a PingFederate server, a DevOps license is required - [Register for the DevOps program here](https://devops.pingidentity.com/how-to/devopsRegistration/)

## Start a PingFederate Docker image to be configured

!!! warning "Using an Existing PingFederate Server"
    If you already have a running PingFederate server that you can reach over HTTPS, you can skip this step. The provider can be used with any PingFederate server.

First, start a PingFederate server using Docker. Your DevOps credentials will be read from the `${HOME}/.pingidentity/config` file. The HTTPS port (default `9999`) must be exposed.

```shell
docker run --name pingfederate_terraform_provider_container \
  -d -p 9031:9031 \
  -d -p 9999:9999 \
  --env-file "${HOME}/.pingidentity/config" \
  -e SERVER_PROFILE_URL=https://github.com/pingidentity/pingidentity-server-profiles.git \
  -e SERVER_PROFILE_BRANCH=terraform-provider-pingfederate-1125 \
  -e SERVER_PROFILE_PATH=terraform-provider-pingfederate/pingfederate \
  pingidentity/pingfederate:$${PINGFEDERATE_PROVIDER_PRODUCT_VERSION:-12.0.0}-latest
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

Using the port mappings from the example above, PingFederate will be available at `https://localhost:9999/pingfederate/app#/`.

If you want to access the API documentation, it is available at `https://localhost:9999/pf-admin-api/api-docs/#/`.

The PingFederate Terraform provider applies configuration at the API endpoints using the `9999` port over HTTPS when accessing the product locally under Docker.

## Determine credentials that are able to configure the server

The configuration API connection established by the provider uses basic authentication. The provider will need the username and password of a user that has permissions to manage server configuration.

In the PingFederate Docker image, the default administrative user has the username `administrator` with password `2FederateM0re`.

## Determine what version of PingFederate you are running

The provider requires that the version of PingFederate is specified.  

You can do this one of two ways:

* Using the `product_version` attribute when configuring the provider:

```shell
provider "pingfederate" {
  ...
  product_version = "12.0.0"
}
```

* Setting the `PING_PRODUCT_VERSION` environment variable to the version of PingFederate you are running:

```shell
export PING_PRODUCT_VERSION=12.0.0
```

You can view the product version using by running a shell in the container and searching for the appropriate environment variable:

```shell
docker container exec -it pingfederate_terraform_provider_container /bin/sh
```

Then, run:

```shell
env | grep PING_PRODUCT_VERSION
```

!!! note "Precedence"
    The `product_version` attribute takes precedence over the `PING_PRODUCT_VERSION` environment variable.

If neither is set, the provider will throw an error.

## Trusting PingFederate certificates

PingFederate generates a self-signed certificate by default, which is presented by the server when connecting. The default self-signed certificate can also be replaced with a custom certificate. The provider has a few ways of configuring trust for the HTTPS connection with the server.

By default, the provider will trust the host's default root CA set when connecting to the server.

The provider also supports an `insecure_trust_all_tls` boolean attribute that enables it to trust all certificates when connecting to the server.

!!! warning "Insecure Trust All TLS"
    The `insecure_trust_all_tls` flag, when set to `true`, is insecure and is intended for development and testing only.  You should not enable this option for production use.

## Use the provider to configure PingFederate

You are now ready to configure the PingFederate server using the provider.  For example:

```shell
terraform {
  required_version = ">=1.4"
  required_providers {
    pingfederate = {
      version = "~> 0.0.1"
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
  # Warning: 'insecure_trust_all_tls' configures the provider to trust any certificate presented by the PingFederate server.
  insecure_trust_all_tls = true
  product_version = "12.0.0"
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

# Update server settings general settings
resource "pingfederate_server_settings_general_settings" "serverSettingsGeneralSettingsExample" {
  datastore_validation_interval_secs          = 300
  disable_automatic_connection_validation     = false
  idp_connection_transaction_logging_override = "NONE"
  request_header_for_correlation_id           = "example"
  sp_connection_transaction_logging_override  = "FULL"
}
```
