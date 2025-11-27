output "access_key" {
  description = "Access key id to access the backend bucket. Export this value as AWS_ACCESS_KEY_ID to access the bucket."
  value       = module.object_storage.credentials["default"].access_key
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret access key to access the backend bucket. Export this value as AWS_SECRET_ACCESS_KEY to access the bucket."
  value       = module.object_storage.credentials["default"].secret_access_key
  sensitive   = true
}

locals {
  backend_file = <<-EOT
terraform {
  backend "s3" {
    bucket       = "${module.object_storage.bucket_name}"
    key          = "tfstate-backend"
    use_lockfile = true
    endpoints = {
      s3 = "https://object.storage.eu01.onstackit.cloud"
    }
    region                      = "eu01"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    skip_requesting_account_id  = true
  }
}
  EOT
}
output "backend_file" {
  description = "Content of the backend configuration file for Terraform."
  value       = <<-EOT
terraform {
  backend "s3" {
    bucket       = "${module.object_storage.bucket_name}"
    key          = "tfstate-backend"
    use_lockfile = true
    endpoints = {
      s3 = "https://object.storage.eu01.onstackit.cloud"
    }
    region                      = "eu01"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    skip_requesting_account_id  = true
  }
}
  EOT
}

output "envrc_file" {
  description = "Content of the .envrc file to set environment variables for accessing the backend bucket."
  sensitive   = true
  value       = <<-EOT
export AWS_ACCESS_KEY_ID="${module.object_storage.credentials["default"].access_key}"
export AWS_SECRET_ACCESS_KEY="${module.object_storage.credentials["default"].secret_access_key}"
  EOT
}