terraform {
  required_version = ">=1.10.1"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">=0.101.0"
    }
  }
}
