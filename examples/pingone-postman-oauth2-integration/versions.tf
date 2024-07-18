terraform {
  required_version = ">= 1.3.0"

  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = ">= 1.0.0, < 2.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1, < 1.0.0"
    }
  }
}

provider "pingone" {}

provider "time" {}
