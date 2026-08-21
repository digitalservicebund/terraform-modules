output "service_account_email" {
  value       = stackit_service_account.this.email
  description = "Email of the created service account"
}
output "custom_role_name" {
  value       = one(stackit_authorization_organization_custom_role.this[*].name)
  description = "Name of the custom role created from var.permissions, null if no permissions were supplied"
}