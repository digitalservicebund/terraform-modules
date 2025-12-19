locals {
  yaml_autocreate_warning = <<-EOT
    ###
    # DO NOT EDIT MANUALLY
    # THIS FILE IS MANAGED BY TERRAFORM
    ###
  EOT
}

resource "stackit_objectstorage_bucket" "bucket" {
  project_id = var.project_id
  name       = var.bucket_name
}

resource "stackit_objectstorage_credentials_group" "credentials_group" {
  # depends_on needed to avoid 409, because of simultaneously requests
  # REF: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket
  depends_on = [stackit_objectstorage_bucket.bucket]
  project_id = var.project_id
  name       = "${var.bucket_name}-cg"
}

resource "stackit_objectstorage_credential" "credential" {
  for_each             = toset(var.credentials_names)
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.credentials_group.credentials_group_id
}

resource "vault_kv_secret_v2" "bucket_credentials" {
  for_each = var.manage_credentials ? toset(var.credentials_names) : []
  mount    = var.secret_manager_instance_id
  name     = "object-storage/${stackit_objectstorage_bucket.bucket.name}/${each.key}"

  data_json = jsonencode({
    access_key        = stackit_objectstorage_credential.credential[each.key].access_key
    secret_access_key = stackit_objectstorage_credential.credential[each.key].secret_access_key
  })
}

resource "local_file" "external_secret_manifest" {
  count = var.manage_credentials ? 1 : 0

  lifecycle {
    precondition {
      # Only create the file if manage_credentials is set (otherwise the resource would not be created at all)
      # and error out if the filename was not provided.
      condition     = var.external_secret_manifest != null && var.kubernetes_namespace != null
      error_message = "You enabled 'manage_credentials' but did not provide 'external_secret_manifest' and 'kubernetes_namespace'."
    }
  }

  filename = var.external_secret_manifest

  content = format("%s%s", local.yaml_autocreate_warning, join("\n---\n", [
    for name in var.credentials_names : yamlencode({
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
