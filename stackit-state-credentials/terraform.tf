terraform {
  required_version = ">1.10.0"

  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = ">=2.1.2"
    }
  }
}
