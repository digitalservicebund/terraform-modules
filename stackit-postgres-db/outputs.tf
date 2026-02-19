output "address" {
  description = "Database host address"
  value       = stackit_postgresflex_user.admin.host
}

output "credentials" {
  description = "Map of user keys to passwords. Empty if managed in Secrets Manager."
  sensitive   = true
  value = merge(
    { (stackit_postgresflex_user.admin.username) = var.manage_user_password ? "" : stackit_postgresflex_user.admin.password },
    {
      for user_key, user_spec in var.user_spec_map :
      user_spec.name => var.manage_user_password ? "" : stackit_postgresflex_user.user[user_key].password
    }
  )
}

output "secret_manager_secret_names" {
  description = "List of secret paths created in STACKIT Secrets Manager"
  value = var.manage_user_password ? concat(
    [vault_kv_secret_v2.postgres_admin_credentials[0].name],
    values(vault_kv_secret_v2.postgres_user_credentials)[*].name
  ) : []
}
