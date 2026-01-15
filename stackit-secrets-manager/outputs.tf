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

output "external_secrets_secret_store_manifest" {
  description = "Kubernetes SecretStore manifest for External Secrets to connect to STACKIT Secrets Manager. Use a null_resource to store this output in a file."
  value = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "SecretStore"
    metadata = {
      name      = "secret-store"
      namespace = var.kubernetes_namespace
    }
    spec = {
      provider = {
        vault = {
          server  = "https://prod.sm.eu01.stackit.cloud"
          path    = stackit_secretsmanager_instance.this.instance_id
          version = "v2"
          auth = {
            userPass = {
              path     = "userpass"
              username = stackit_secretsmanager_user.external_secrets.username
              secretRef = {
                name = "secrets-manager-password"
                key  = "password"
              }
            }
          }
        }
      }
    }
  })
}

output "external_secrets_secret_manifest" {
  description = "Kubernetes Secret manifest containing the password for the External Secrets user. Please use kubeseal to create a sealed secret from this manifest."
  sensitive   = true
  value = format(
    "# DO NOT COMMIT THIS! USE KUBESEAL TO CREATE A SEALED SECRET INSTEAD\n%s",
    yamlencode({
      apiVersion = "v1"
      kind       = "Secret"
      metadata = {
        name      = "secrets-manager-password"
        namespace = var.kubernetes_namespace
      }
      type = "Opaque"
      stringData = {
        password = stackit_secretsmanager_user.external_secrets.password
      }
    })
  )
}