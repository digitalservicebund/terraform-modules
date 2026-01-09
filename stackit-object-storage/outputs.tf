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
  description = "Credentials to manage S3 bucket via Terraform"
  value = {
    access_key        = stackit_objectstorage_credential.terraform_credentials.access_key
    secret_access_key = stackit_objectstorage_credential.terraform_credentials.secret_access_key
  }
}

output "bucket_name" {
  value = stackit_objectstorage_bucket.bucket.name
}
