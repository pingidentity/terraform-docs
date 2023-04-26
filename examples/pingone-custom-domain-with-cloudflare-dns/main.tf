resource "pingone_environment" "my_environment" {
  name        = "Terraform Example - Custom Domain with Cloudflare DNS"
  description = "This environment was created by Terraform as an example of how to set up custom domain configuration with Cloudflare DNS."
  type        = "SANDBOX"
  license_id  = var.pingone_license_id

  default_population {
    name        = "My Default Population"
    description = "My new population for users"
  }

  service {
    type = "SSO"
  }
}

resource "pingone_custom_domain" "my_custom_domain" {
  environment_id = pingone_environment.my_environment.id

  domain_name = format("%s.%s", var.custom_domain_cname, var.cloudflare_domain_zone)
}

data "cloudflare_zone" "domain" {
  name = var.cloudflare_domain_zone
}

resource "cloudflare_record" "cname_record" {
  zone_id = data.cloudflare_zone.domain.id

  name  = var.custom_domain_cname
  value = pingone_custom_domain.my_custom_domain.canonical_name
  type  = "CNAME"
  ttl   = 3600
}

resource "pingone_custom_domain_verify" "my_custom_domain" {
  environment_id   = pingone_environment.my_environment.id
  custom_domain_id = pingone_custom_domain.my_custom_domain.id

  depends_on = [
    cloudflare_record.cname_record
  ]
}

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
