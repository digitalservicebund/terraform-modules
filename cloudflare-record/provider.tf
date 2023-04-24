terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }
  }
  required_version = ">= 1.3.9"
}

# Configure the Cloudflare Provider
provider "cloudflare" {
  api_token = "${var.cloudflare_api_token}"
}