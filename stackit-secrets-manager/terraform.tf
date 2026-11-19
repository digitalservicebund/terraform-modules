terraform {
  required_version = ">=1.10.1"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">=0.65.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">=5.3.0"
    }
  }
}
