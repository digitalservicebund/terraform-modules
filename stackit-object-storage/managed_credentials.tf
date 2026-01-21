
resource "vault_kv_secret_v2" "bucket_credentials" {
  for_each = var.manage_credentials ? var.credentials : {}
  mount    = var.secret_manager_instance_id
  name     = "object-storage/${stackit_objectstorage_bucket.bucket.name}/${each.key}"

  data_json = jsonencode({
    access_key        = stackit_objectstorage_credential.credential[each.key].access_key
    secret_access_key = stackit_objectstorage_credential.credential[each.key].secret_access_key
  })
}

resource "local_file" "external_secret_manifest" {
  count = var.manage_credentials && var.enable_manifest_creation ? 1 : 0

  lifecycle {
    precondition {
      # Only create the file if manage_credentials is set (otherwise the resource would not be created at all)
      # and error out if the filename was not provided.
      condition     = var.external_secret_manifest != null && var.kubernetes_namespace != null
      error_message = "You enabled 'manage_credentials' but did not provide 'external_secret_manifest' and 'kubernetes_namespace'. Please add them to your module call or disable the manifest creation with 'enable_manifest_creation = false'."
    }
  }

  filename = var.external_secret_manifest

  content = format("%s%s", local.yaml_autocreate_warning, join("\n---\n", [
    for name, role in var.credentials : yamlencode({
      apiVersion = "external-secrets.io/v1"
      kind       = "ExternalSecret"
      metadata = {
        name      = "${var.bucket_name}-bucket-credentials-${name}"
        namespace = var.kubernetes_namespace
      }
      spec = {
        refreshInterval = "15m"
        secretStoreRef = {
          name = "secret-store"
          kind = "SecretStore"
        }
        data = [
          {
            secretKey = "access_key"
            remoteRef = {
              key      = "object-storage/${stackit_objectstorage_bucket.bucket.name}/${name}"
              property = "access_key"
            }
          },
          {
            secretKey = "secret_access_key"
            remoteRef = {
              key      = "object-storage/${stackit_objectstorage_bucket.bucket.name}/${name}"
              property = "secret_access_key"
            }
          }
        ]
      }
    })
  ]))
}

