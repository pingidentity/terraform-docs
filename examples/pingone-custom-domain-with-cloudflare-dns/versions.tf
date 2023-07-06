terraform {
  required_version = ">= 1.1.0"

  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = ">= 0.17.1, < 1.0.0"
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
