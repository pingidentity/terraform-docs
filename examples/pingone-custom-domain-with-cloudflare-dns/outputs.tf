output "pingone_self_service_endpoint" {
    description = "The PingOne self-service endpoint for the environment.  The PingOne Self-Service application will use the custom domain if configured correctly."
    value = module.pingone_utils.pingone_environment_self_service_endpoint
}

output "pingone_oidc_well_known_endpoint" {
    description = "The PingOne OIDC well-known endpoint for the environment.  This endpoint will use the custom domain if configured correctly."
    value = module.pingone_utils.pingone_environment_oidc_discovery_endpoint
}

output "pingone_environment_name" {
  description = "The environment name created by the example"
  value       = pingone_environment.my_environment.name
}