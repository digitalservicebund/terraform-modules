terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }
  }
}

# Configure the Cloudflare Provider
provider "cloudflare" {
  api_token = "${var.cloudflare_api_token}"
}