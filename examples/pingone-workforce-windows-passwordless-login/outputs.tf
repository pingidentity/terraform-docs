output "windows_login_passwordless_ca_certificate_pem_file" {
  description = "An export of the generated CA issuing certificate, in PEM format, to publish to Active Directory."
  value       = data.pingone_certificate_export.ad_issuance_certificate.pem_file
}

output "windows_login_passwordless_agent_client_id" {
  description = "The OIDC client ID to use when installing the Windows Login Passwordless Desktop Agent application."
  value       = pingone_application.windows_login_passwordless_app.oidc_options.client_id
}


output "windows_login_passwordless_agent_client_secret" {
  description = "The OIDC client secret to use when installing the Windows Login Passwordless Desktop Agent application."
  value       = data.pingone_application_secret.windows_login_passwordless_app.secret
  sensitive   = true
}

output "windows_login_passwordless_agent_discovery_endpoint_url" {
  description = "The OIDC Discovery Endpoint URL to use when installing the Windows Login Passwordless Desktop Agent application."
  value       = module.pingone_utils.pingone_environment_oidc_discovery_endpoint
}