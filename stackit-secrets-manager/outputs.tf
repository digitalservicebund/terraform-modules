output "instance_id" {
  value       = stackit_secretsmanager_instance.this.instance_id
  description = "Instance ID of the secrets manager instance"
}

output "external_secrets_username" {
  value       = stackit_secretsmanager_user.external_secrets.username
  description = "Username to be used by external secrets provider"
}
output "external_secrets_password" {
  value       = stackit_secretsmanager_user.external_secrets.password
  sensitive   = true
  description = "Password to be used by external secrets provider"
}

output "terraform_username" {
  value       = stackit_secretsmanager_user.terraform.username
  description = "Username to be used by terraform."
}
output "terraform_password" {
  value       = stackit_secretsmanager_user.terraform.password
  sensitive   = true
  description = "Password to be used by terraform."
}