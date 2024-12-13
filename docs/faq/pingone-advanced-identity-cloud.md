# Frequently Asked Questions - PingOne Advanced Identity Cloud

## Can I manage AM and IDM configuration using the Terraform provider?

The PingOne provider does not yet support management of AM and IDM configuration in the Advanced Identity Cloud tenant.  The initial release of the provider focuses on just the tenant management interfaces.

## I get permission denied errors when attempting to use the Terraform provider

Check the service account's assigned scopes. The service account must have the following scopes assigned:

- `fr:idc:certificate:*`
- `fr:idc:content-security-policy:*`
- `fr:idc:cookie-domain:*`
- `fr:idc:custom-domain:*`
- `fr:idc:esv:*`
- `fr:idc:promotion:*`
- `fr:idc:sso-cookie:*` 

Please see the [Service account](https://docs.pingidentity.com/pingoneaic//latest/tenants/service-accounts.html) guide on how to create and modify service accounts.
