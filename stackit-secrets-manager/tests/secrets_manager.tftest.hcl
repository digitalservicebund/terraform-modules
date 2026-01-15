mock_provider "stackit" {
  mock_resource "stackit_secretsmanager_instance" {
    defaults = {
      instance_id = "ff0253d0-bd75-4ee6-a33a-63b41c320260"
    }
  }

  mock_resource "stackit_secretsmanager_user" {
    defaults = {
      username = "username"
      password = "password"
    }
  }
}

mock_provider "vault" {
  mock_resource "vault_generic_endpoint" {
  }
}

variables {
  project_id = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
}

run "basic_config" {
  command = apply

  variables {
    name = "platform-secrets"
  }

  assert {
    condition     = stackit_secretsmanager_instance.this.name == "platform-secrets"
    error_message = "Secrets manager name does not match expected value"
  }

  assert {
    condition     = vault_generic_endpoint.config.data_json != null && vault_generic_endpoint.config.data_json != ""
    error_message = "Config data should be set"
  }
}

run "external_secrets_outputs" {
  command = apply

  variables {
    name                 = "platform-secrets"
    kubernetes_namespace = "platform"
  }

  assert {
    condition     = output.external_secrets_secret_store_manifest == <<EOT
"apiVersion": "external-secrets.io/v1"
"kind": "SecretStore"
"metadata":
  "name": "secret-store"
  "namespace": "platform"
"spec":
  "provider":
    "vault":
      "auth":
        "userPass":
          "path": "userpass"
          "secretRef":
            "key": "password"
            "name": "secrets-manager-password"
          "username": "username"
      "path": "ff0253d0-bd75-4ee6-a33a-63b41c320260"
      "server": "https://prod.sm.eu01.stackit.cloud"
      "version": "v2"
EOT
    error_message = "External Secrets SecretStore manifest is incorrect"
  }

  assert {
    condition     = nonsensitive(output.external_secrets_secret_manifest) == <<EOT
# DO NOT COMMIT THIS! USE KUBESEAL TO CREATE A SEALED SECRET INSTEAD
"apiVersion": "v1"
"kind": "Secret"
"metadata":
  "name": "secrets-manager-password"
  "namespace": "platform"
"stringData":
  "password": "password"
"type": "Opaque"
EOT
    error_message = "External Secrets Secret manifest is incorrect"
  }
}
