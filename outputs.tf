output "service_account_email" {
  value       = stackit_service_account.this.email
  description = "Email of the created service account"
}
output "custom_role_name" {
  value = one(concat(
    stackit_authorization_project_custom_role.this[*].name,
    stackit_authorization_folder_custom_role.this[*].name,
    stackit_authorization_organization_custom_role.this[*].name,
  ))
  description = "Name of the custom role created from var.permissions, null if no permissions were supplied"
}

output "role_scope" {
  value       = local.role_scope
  description = "The level (project, folder or organization) the custom role and role assignments are created on"
}

output "resource_id" {
  value       = local.resource_id
  description = "ID of the resource (project, folder or organization) the custom role and role assignments are created on"
}
