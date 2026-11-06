output "address" {
  description = "Database host address"
  value       = stackit_postgresflex_instance.this.connection_info.write.host
}

output "credentials" {
  description = "Map of user keys to passwords. Empty if managed in Secrets Manager."
  sensitive   = true
  value = merge(
    { (stackit_postgresflex_user.admin.username) = var.manage_user_password ? "" : stackit_postgresflex_user.admin.password },
    {
      for name, user in local.additional_users_map :
      name => var.manage_user_password ? "" : stackit_postgresflex_user.user[name].password
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

output "project_id" {
  description = "STACKIT project ID of the Postgres Flex instance"
  value       = stackit_postgresflex_instance.this.project_id
}

output "instance_id" {
  description = "Postgres Flex instance ID"
  value       = stackit_postgresflex_instance.this.instance_id
}

output "secret_manager_mount" {
  description = "Secrets Manager mount holding the user credentials. Null if manage_user_password is false."
  value       = var.manage_user_password ? var.secret_manager_instance_id : null
}

output "users" {
  description = "Map of username to its Postgres Flex user_id and Secrets Manager secret_path (null if manage_user_password is false)."
  value = merge(
    {
      (local.admin_username) = {
        user_id     = stackit_postgresflex_user.admin.user_id
        secret_path = var.manage_user_password ? local.admin_secret_path : null
      }
    },
    {
      for k, u in local.additional_users_map : u.name => {
        user_id     = stackit_postgresflex_user.user[k].user_id
        secret_path = var.manage_user_password ? local.user_secret_paths[k] : null
      }
    }
  )
}
