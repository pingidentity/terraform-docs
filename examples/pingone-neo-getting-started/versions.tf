terraform {
  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = "~> 0.16.0"
    }
  }
}

provider "pingone" {
  # Configuration options
}