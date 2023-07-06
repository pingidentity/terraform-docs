terraform {
  required_version = ">= 1.1.0"

  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = ">= 0.17.1, < 1.0.0"
    }
  }
}

provider "pingone" {
  # Configuration options
}