output "credentials" {
  sensitive   = true
  description = "Credentials to access the S3 bucket."
  value = var.manage_credentials ? {} : {
    for name in var.credentials_names : name => {
      access_key        = stackit_objectstorage_credential.credential[name].access_key
      secret_access_key = stackit_objectstorage_credential.credential[name].secret_access_key
    }
  }
}

output "bucket_name" {
  value = stackit_objectstorage_bucket.state_bucket.name
}

locals {
  manifest_list = [
    for name in var.credentials_names : <<EOF
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: bucket-credentials-${name}
  namespace: ${var.kubernetes_namespace}
spec:
  refreshInterval: "15m"
  secretStoreRef:
    name: secret-store
    kind: SecretStore
  target:
    name: bucket-credentials-${name}
  data:
    - secretKey: access_key
      remoteRef:
        key: object-storage/${stackit_objectstorage_bucket.state_bucket.name}/${name}
        property: access_key
    - secretKey: secret_access_key
      remoteRef:
        key: object-storage/${stackit_objectstorage_bucket.state_bucket.name}/${name}
        property: secret_access_key
EOF
  ]
  external_secrets_manifest = var.manage_credentials ? join("\n---\n", local.manifest_list) : ""
}

output "external_secret_manifest" {
  description = "Kubernetes External Secret manifest to fetch the bucket credentials from STACKIT Secrets Manager"
  value       = var.manage_credentials ? local.external_secrets_manifest : ""
}
