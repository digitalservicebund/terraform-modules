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

output "backend_file" {
  description = "Content of the backend configuration file for Terraform."
  value       = local.backend_file
}

output "envrc_file" {
  description = "Content of the .envrc file to set environment variables for accessing the backend bucket."
  value       = local.envrc_file
}

output "onepassword_command" {
  sensitive   = true
  value       = local.onepassword_command
  description = "The 1Password CLI command that needs to be executed to add the bucket credentials to 1Password."
}