output "address" {
  description = "Database host address"
  value       = stackit_postgresflex_user.user.host
}

output "username" {
  description = "Database username"
  value       = stackit_postgresflex_user.user.username
}

output "password" {
  description = "Database password. This will be emtpy if the password is managed in STACKIT Secrets Manager."
  value       = var.manage_user_password ? "" : stackit_postgresflex_user.user.password
  sensitive   = true
}

output "secret_manager_secret_name" {
  description = "Name of the secret in STACKIT Secrets Manager where the database credentials are stored"
  value       = var.manage_user_password ? vault_kv_secret_v2.postgres_credentials[0].name : ""
}


locals {
  external_secrets_manifest = <<EOF
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: ${var.kubernetes_namespace}
spec:
  refreshInterval: "15m"
  secretStoreRef:
    name: secret-store
    kind: SecretStore
  data:
    - secretKey: username
      remoteRef:
        key: ${var.manage_user_password ? vault_kv_secret_v2.postgres_credentials[0].name : ""}
        property: username
    - secretKey: password
      remoteRef:
        key: ${var.manage_user_password ? vault_kv_secret_v2.postgres_credentials[0].name : ""}
        property: password
    - secretKey: host
      remoteRef:
        key: ${var.manage_user_password ? vault_kv_secret_v2.postgres_credentials[0].name : ""}
        property: host
EOF
}
output "external_secret_manifest" {
  description = "Kubernetes External Secret manifest to fetch the database credentials from STACKIT Secrets Manager"
  value       = var.manage_user_password ? local.external_secrets_manifest : ""
}