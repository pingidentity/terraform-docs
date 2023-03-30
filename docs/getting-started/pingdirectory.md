# Getting Started - PingDirectory

<div class="banner" onclick="window.open('https://registry.terraform.io/providers/pingidentity/pingdirectory/latest','');">
    <img class="assets" src="../../img/logos/tf-logo.svg" alt="Terraform logo" />
    <span class="caption">
        <a class="assetlinks" href="https://registry.terraform.io/providers/pingidentity/pingdirectory/latest" target=”_blank”>Registry</a>
    </span>
</div>

## Requirements

* Terraform CLI 1.1+
* A running PingDirectory server accessible over HTTPS, or Docker CLI to start one.
* When using Docker to start a PingDirectory server, a DevOps license will be required - [Register for the DevOps program here](https://devops.pingidentity.com/how-to/devopsRegistration/)

## Start a PingDirectory Docker image to be configured

!!! warning "Using an Existing PingDirectory Server"
    If you already have a running PingDirectory server that you can reach over HTTPS, you can skip this step. The provider can be used with any PingDirectory server.

First, start a PingDirectory server using Docker. Your DevOps credentials will be read from the `${HOME}/.pingidentity/config` file. The HTTPS port (default `1443`) must be exposed.

```
docker run --name pingdirectory_terraform_provider_container \
		-d -p 1443:1443 \
		-d -p 1389:1389 \
		-e TAIL_LOG_FILES= \
		--env-file "${HOME}/.pingidentity/config" \
		pingidentity/pingdirectory:${PINGDIRECTORY_TAG:-9.2.0.0-latest}
```

After starting the container, follow the logs until the server becomes available.

```
docker logs -f pingdirectory_terraform_provider_container
```

Once you see the following message in the container logs, the server is ready to receive requests from the provider:

```
Setting Server to Available
```

## Ensure the Configuration HTTP Servlet Extension is enabled

The PingDirectory Terraform provider applies configuration via the Configuration HTTP servlet extension, which must be enabled for the server's HTTPS connection handler.

This is already configured by default in PingDirectory, including when running in Docker.

If you have disabled the Configuration HTTP servlet extension on your server, you can re-enable it with dsconfig:

```
dsconfig set-connection-handler-prop --handler-name "HTTPS Connection Handler" --add http-servlet-extension:Configuration
```

## Determine what port the server is using for HTTPS connections

The PingDirectory Docker image uses port `1443` for HTTPS by default. 

To determine what port you are using, you can use the `status` command, and examine the output for a block containing the HTTPS port:

```
          --- Connection Handlers ---
Address:Port : Protocol : State    : Name
-------------:----------:----------:-------------------------
0.0.0.0:1389 : LDAP     : Enabled  : LDAP Connection Handler
0.0.0.0:1443 : HTTPS    : Enabled  : HTTPS Connection Handler
0.0.0.0:1636 : LDAPS    : Enabled  : LDAPS Connection Handler
```

## Determine credentials that are able to configure the server

The Configuration API used by the provider uses basic authentication. The provider will need the username and password of a user that has permissions to manage server configuration.

In the PingDirectory Docker image, the default root user has a bind DN of `cn=administrator` and password `2FederateM0re`.

## Determine what version of PingDirectory you are running

The provider requires that the version of PingDirectory is specified via the `product_version` attribute, or the `PINGDIRECTORY_PROVIDER_PRODUCT_VERSION` environment variable.

You can view the product version using the `status` command. Look for the Server Details section:

```
          --- Server Details ---
Host Name:            ...
Instance Name:        ...
Administrative Users: cn=administrator
Installation Path:    /opt/out/instance
Server Version:       Ping Identity Directory Server 9.2.0.0
```

## Trusting PingDirectory certificates

PingDirectory generates a self-signed certificate by default, which is presented by the server's HTTPS connection handler. The default self-signed certificate can also be replaced with a custom certificate. The provider has a few ways of configuring trust for the HTTPS connection with the server.

By default, the provider will trust the host's default root CA set when connecting to the server.

The provider also supports an `insecure_trust_all_tls` boolean attribute (configurable with environment variable `PINGDIRECTORY_PROVIDER_INSECURE_TRUST_ALL_TLS`) that allows simply trusting all certificates when connecting to the server. This is insecure and should not be used in production.

If you need to provide CA certificates for the provider to trust, you can use the `ca_certificate_pem_files` attribute. This attribute allows providing a set of paths to files containing PEM-encoded CA certificates to be trusted. The `PINGDIRECTORY_PROVIDER_CA_CERTIFICATE_PEM_FILES` environment variable can also be used, with commas to delimit multiple PEM file paths if necessary.

If you want to trust the default self-signed certificate of the PingDirectory server, you can export the certificate from the server's keystore using the `manage-certificates` command-line tool.

```
> manage-certificates export-certificate --keystore config/keystore --alias server-cert

-----BEGIN CERTIFICATE-----
...
...
...
-----END CERTIFICATE-----
```

Write the output of that command to a file (we will use `cert.pem` as the filename in the example below). Then you can include the path to that file in the `ca_certificate_pem_files` attribute when using the provider.

## Use the provider to configure PingDirectory

You are now ready to configure the PingDirectory server with the provider.

```
terraform {
  required_version = ">=1.1"
  required_providers {
    pingdirectory = {
      source = "pingidentity/pingdirectory"
    }
  }
}

provider "pingdirectory" {
  username   = "cn=administrator"
  password   = "2FederateM0re"
  https_host = "https://localhost:1443"
  ca_certificate_pem_files = ["cert.pem"]
  product_version = "9.2.0.0"
}

# Create a sample location
resource "pingdirectory_location" "myLocation" {
  id          = "MyLocation"
  description = "My description"
}

# Update the default global configuration to enable encryption
resource "pingdirectory_default_global_configuration" "global" {
  encrypt_data = true
}
```
