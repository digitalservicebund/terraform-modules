output "secret_manager_secret_name" {
  description = "Name of the secret in STACKIT Secrets Manager where the credentials are stored"
  value       = vault_kv_secret_v2.credentials.name
}
