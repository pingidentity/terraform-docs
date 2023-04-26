terraform {
  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = "~> 0.13.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.4.0"
    }
  }
}

provider "cloudflare" {
  # Configuration options
}

provider "pingone" {
  # Configuration options
}
