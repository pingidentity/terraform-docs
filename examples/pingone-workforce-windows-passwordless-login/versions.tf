terraform {
  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = "~> 0.13.0"
    }
  }
}

provider "pingone" {
  # Configuration options
}