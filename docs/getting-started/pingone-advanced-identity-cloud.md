# Getting Started - PingOne Advanced Identity Cloud

<div class="banner" onclick="window.open('https://registry.terraform.io/providers/pingidentity/identitycloud/latest','');">
    <img class="assets" src="../../img/logos/tf-logo.svg" alt="Terraform logo" />
    <span class="caption">
        <a class="assetlinks" href="https://registry.terraform.io/providers/pingidentity/identitycloud/latest" target=”_blank”>Registry</a>
    </span>
</div>

## Requirements

* Terraform CLI 1.4+
* A licensed PingOne Advanced Identity Cloud subscription - [Request a Demo](https://www.pingidentity.com/en/platform/pingone-advanced-identity-cloud.html)
* Administrator access to the [PingOne Advanced Identity Cloud Administration Console](https://docs.pingidentity.com/pingoneaic/latest/admin-uis.html)

## PingOne Advanced Identity Cloud Subscription

To get started using the PingOne Advanced Identity Cloud Terraform provider, first you'll need an active PingOne Advanced Identity Cloud subscription. [Request a demo](https://www.pingidentity.com/en/platform/pingone-advanced-identity-cloud.html), or read more about Ping Identity at [pingidentity.com](https://www.pingidentity.com)

## Configure PingOne Advanced Identity Cloud for Terraform access

The following steps describe how to connect Terraform to your PingOne Advanced Identity Cloud instance:

1. Log in to your **Advanced Identity Cloud Administration Console**, if necessary using the [Getting started with PingOne Advanced Identity Cloud](https://docs.pingidentity.com/pingoneaic//latest/getting-started.html) guide.
2. Create a new service account for Terraform access, if necessary using the [Service accounts](https://docs.pingidentity.com/pingoneaic/latest/tenants/service-accounts.html) guide.  Provide an appropriate name (for example, "Terraform Automation") and ensure that the service account has the following scopes assigned:
   - `fr:idc:certificate:*`
   - `fr:idc:content-security-policy:*`
   - `fr:idc:cookie-domain:*`
   - `fr:idc:custom-domain:*`
   - `fr:idc:esv:*`
   - `fr:idc:promotion:*`
   - `fr:idc:sso-cookie:*` 
3. Ensure that the private key is downloaded and kept safe.  This key, along with the service account ID, are the credentials the Terraform provider needs to authenticate to the service API.
4. Start your Terraform project! The Advanced Identity Cloud tenant is ready for Terraform use. Proceed on to the [Terraform Registry documentation](https://registry.terraform.io/providers/pingidentity/identitycloud/latest) to configure and use the Terraform provider.