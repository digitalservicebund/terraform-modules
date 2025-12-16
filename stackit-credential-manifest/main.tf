resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "~!@#%^*-_=+?"
}

resource "vault_kv_secret_v2" "credentials" {
  mount = var.secret_manager_instance_id
  name  = "${var.vault_name}/${var.user}"
  data_json = jsonencode({
    username = var.user
    password = random_password.password.result
  })
}

resource "local_file" "external_secret_manifest" {
  filename = var.manifest_file

  # We construct the YAML content directly here
  content = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "${var.manifest_name}"
      namespace = "${var.kubernetes_namespace}"
    }
    spec = {
      refreshInterval = "15m"
      secretStoreRef = {
        name = "secret-store"
        kind = "SecretStore"
      }
      data = [
        {
          secretKey = "username"
          remoteRef = {
            key      = "${var.vault_name}/${var.user}"
            property = "username"
          }
        },
        {
          secretKey = "$password"
          remoteRef = {
            key      = "${var.vault_name}/${var.user}"
            property = "password"
          }
        }
      ]
    }
  })
}