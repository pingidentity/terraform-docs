resource "pingone_application" "postman" {
  environment_id = pingone_environment.my_environment.id

  name        = "Postman"
  description = "Client to access PingOne API using Postman's OAuth 2.0 Authorization type."
  enabled     = true

  hidden_from_app_portal = false

  icon = {
    href = pingone_image.postman_logo.uploaded_image.href
    id   = pingone_image.postman_logo.id
  }

  oidc_options = {
    type = "WORKER"

    grant_types = [
      "AUTHORIZATION_CODE",
      "REFRESH_TOKEN",
    ]
    response_types = [
      "CODE",
    ]

    pkce_enforcement           = "S256_REQUIRED"
    token_endpoint_auth_method = "NONE"

    redirect_uris = [
      "https://oauth.pstmn.io/v1/callback",
    ]
    allow_wildcard_in_redirect_uris = false

    refresh_token_duration                      = 2592000
    refresh_token_rolling_duration              = 15552000
    refresh_token_rolling_grace_period_duration = 0
  }
}
