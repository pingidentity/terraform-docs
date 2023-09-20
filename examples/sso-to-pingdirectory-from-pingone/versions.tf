terraform {
  required_version = ">= 1.2.0"

  required_providers {
    pingdirectory = {
      source  = "pingidentity/pingdirectory"
      version = ">= 1.0.0, < 2.0.0"
    }
    pingone = {
      source  = "pingidentity/pingone"
      version = ">= 0.21.0, < 1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1, < 1.0.0"
    }
  }
}

provider "pingdirectory" {
  product_version = "9.3.0.0"
}

provider "pingone" {}

provider "time" {}
