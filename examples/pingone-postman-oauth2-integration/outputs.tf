output "pingone_environment_name" {
  description = "The environment name created by the example"
  value       = pingone_environment.my_environment.name
}

output "postman_application_client_id" {
  description = "The client ID used for the Postman OAuth 2.0 authorization type integration.  As the application is configured to use PKCE, the client secret is not required."
  value       = pingone_application.postman.oidc_options.client_id
}

output "postman_application_authorization_endpoint" {
  description = "The environment's authorization endpoint used for the Postman OAuth 2.0 authorization type integration."
  value       = module.pingone_utils.pingone_environment_authorization_endpoint
}

output "postman_application_token_endpoint" {
  description = "The environment's token endpoint used for the Postman OAuth 2.0 authorization type integration."
  value       = module.pingone_utils.pingone_environment_token_endpoint
}
