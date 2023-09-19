// Create the custom domain in the environment.
resource "pingone_custom_domain" "my_custom_domain" {
  environment_id = pingone_environment.my_environment.id

  domain_name = format("%s.%s", var.custom_domain_cname, var.cloudflare_domain_zone)
}

// Get details of the domain zone from Cloudflare
data "cloudflare_zone" "domain" {
  name = var.cloudflare_domain_zone
}

// Create a DNS record in Cloudflare for the custom domain.
resource "cloudflare_record" "cname_record" {
  zone_id = data.cloudflare_zone.domain.id

  name  = var.custom_domain_cname
  value = pingone_custom_domain.my_custom_domain.canonical_name
  type  = "CNAME"
  ttl   = 3600
}

// Proceed to verify the custom domain in PingOne, now the DNS record has been created
resource "pingone_custom_domain_verify" "my_custom_domain" {
  environment_id   = pingone_environment.my_environment.id
  custom_domain_id = pingone_custom_domain.my_custom_domain.id

  depends_on = [
    cloudflare_record.cname_record
  ]
}

// Once the custom domain is verified in PingOne, apply valid TLS certificates to make the custom domain active.
resource "pingone_custom_domain_ssl" "my_custom_domain" {
  environment_id   = pingone_environment.my_environment.id
  custom_domain_id = pingone_custom_domain.my_custom_domain.id

  certificate_pem_file               = var.certificate_pem_file
  intermediate_certificates_pem_file = var.intermediate_certificates_pem_file
  private_key_pem_file               = var.private_key_pem_file

  depends_on = [
    pingone_custom_domain_verify.my_custom_domain
  ]
}
