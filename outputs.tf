output "credentials" {
  sensitive   = true
  description = "Credentials to access the S3 bucket. Only available if `manage_credentials` is false"
  value = var.manage_credentials ? {} : {
    for name, role in var.credentials : name => {
      access_key        = stackit_objectstorage_credential.credential[name].access_key
      secret_access_key = stackit_objectstorage_credential.credential[name].secret_access_key
    }
  }
}

output "terraform_credentials" {
  sensitive   = true
  description = "Credentials to manage buckets via Terraform. Use these credentials when configuring the AWS provider. This will be empty if `terraform_credentials_group_id` is provided."
  value = var.terraform_credentials_group_id != null ? {} : {
    access_key        = stackit_objectstorage_credential.terraform_credentials[0].access_key
    secret_access_key = stackit_objectstorage_credential.terraform_credentials[0].secret_access_key
  }
}

output "terraform_credentials_group_id" {
  description = "The ID of the credentials group used by Terraform to manage the S3 bucket."
  value       = var.terraform_credentials_group_id != null ? var.terraform_credentials_group_id : stackit_objectstorage_credentials_group.terraform_credentials_group[0].credentials_group_id
}

output "bucket_name" {
  value = stackit_objectstorage_bucket.bucket.name
}
