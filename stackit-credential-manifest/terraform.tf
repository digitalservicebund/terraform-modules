terraform {
  required_version = ">1.10.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">=5.3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.6.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.7.2"
    }
  }
}
