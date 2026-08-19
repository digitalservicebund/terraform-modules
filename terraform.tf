terraform {
  required_version = ">1.10.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">=2.6.1"
    }
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
