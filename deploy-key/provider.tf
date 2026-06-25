terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.12"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.3.0"
    }
  }
}

provider "github" {
  owner = "digitalservicebund"
}
