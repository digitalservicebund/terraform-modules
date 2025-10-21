output "credentials" {
  sensitive   = true
  description = "Credentials to access the S3 bucket."
  value = {
    for name in var.credentials_names : name => {
      access_key        = stackit_objectstorage_credential.credential[name].access_key
      secret_access_key = stackit_objectstorage_credential.credential[name].secret_access_key
    }
  }
}

output "bucket_name" {
  value = stackit_objectstorage_bucket.state_bucket.name
}