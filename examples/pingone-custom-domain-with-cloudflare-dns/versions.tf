terraform {
  required_version = ">= 1.2.0"

  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = ">= 0.21.0, < 1.0.0"
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
