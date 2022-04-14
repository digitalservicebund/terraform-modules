terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.3.0"
    }
  }
}

provider "github" {
  owner = "digitalservice4germany"
}
