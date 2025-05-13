terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.97.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1" // Only Germany is supported
}