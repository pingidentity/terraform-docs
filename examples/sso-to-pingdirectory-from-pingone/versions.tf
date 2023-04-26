terraform {
  required_providers {
    pingdirectory = {
      source  = "pingidentity/pingdirectory"
      version = "~> 0.4.0"
    }
    pingone = {
      source  = "pingidentity/pingone"
      version = "~> 0.13.0"
    }
  }
}

provider "pingdirectory" {
  # Configuration options
}

provider "pingone" {
  # Configuration options
}