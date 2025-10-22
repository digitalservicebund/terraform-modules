mock_provider "stackit" {
  mock_resource "stackit_postgresflex_instance" {
    defaults = {
      instance_id = "87778dd7-a506-45e8-9cd8-134585230603"
    }
  }

  mock_resource "stackit_postgresflex_user" {
    defaults = {
      password = "password"
      host     = "https://example.com"
    }
  }

  mock_resource "stackit_postgresflex_database" {
  }
}

mock_provider "vault" {
  mock_resource "vault_kv_secret_v2" {
  }
}

# Test 1: Basic instance creation with required variables
run "basic_instance_creation" {
  command = apply

  variables {
    name                 = "test-postgres"
    project_id           = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    cpu                  = 2
    memory               = 4
    engine_version       = "17"
    disk_size            = 10
    acls                 = ["10.0.0.0/16"]
    manage_user_password = false
  }

  assert {
    condition     = stackit_postgresflex_instance.this.name == "test-postgres"
    error_message = "Instance name should be 'test-postgres'"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.project_id == "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    error_message = "Project ID should match input"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.flavor.cpu == 2
    error_message = "flavor CPU should match input"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.flavor.ram == 4
    error_message = "flavor RAM should match input"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.version == "17"
    error_message = "Version should be '17'"
  }

  assert {
    condition     = stackit_postgresflex_instance.this.storage.size == 10
    error_message = "Storage size should be 10"
  }

  assert {
    condition     = length(stackit_postgresflex_instance.this.acl) == 1
    error_message = "ACL length should match input"
  }
  assert {
    condition     = stackit_postgresflex_instance.this.acl[0] == "10.0.0.0/16"
    error_message = "ACLs should match input"
  }

  assert {
    condition     = output.address != "https"
    error_message = "The address output should be set correctly"
  }

  assert {
    condition     = nonsensitive(output.password) == "password"
    error_message = "The password should be available as output"
  }

  assert {
    condition     = output.username == "test-postgres"
    error_message = "The username should be similar to the instance name"
  }

  assert {
    condition     = stackit_postgresflex_database.database.name == "test-postgres"
    error_message = "The database name should be similar to the instance name"
  }

  assert {
    condition     = stackit_postgresflex_database.database.owner == stackit_postgresflex_user.user.username
    error_message = "The database owner should be the user created by this module"
  }
}

# Test 2: Instance creation with manage_user_password enabled
run "manage_user_password_enabled" {
  command = apply

  variables {
    name                       = "test-postgres-secrets"
    project_id                 = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    cpu                        = 2
    memory                     = 4
    engine_version             = "17"
    disk_size                  = 10
    acls                       = [""]
    manage_user_password       = true
    secret_manager_instance_id = "secrets-manager-instance-id"
    kubernetes_namespace       = "platform"
  }

  assert {
    condition     = vault_kv_secret_v2.postgres_credentials[0].name == "postgres/test-postgres-secrets"
    error_message = "Vault secret name should match expected format"
  }
  assert {
    condition     = vault_kv_secret_v2.postgres_credentials[0].mount == "secrets-manager-instance-id"
    error_message = "Vault secret mount should match the provided secret_manager_instance_id"
  }
  assert {
    condition = nonsensitive(vault_kv_secret_v2.postgres_credentials[0].data_json) == jsonencode({
      username = "test-postgres-secrets"
      password = "password"
      host     = "https://example.com"
    })
    error_message = "Vault secret should contain the correct database credentials"
  }

  assert {
    condition     = output.secret_manager_secret_name == "postgres/test-postgres-secrets"
    error_message = "The secret_manager_secret_name output should be set correctly"
  }

  assert {
    condition     = output.password == ""
    error_message = "The password output should be empty when manage_user_password is true"
  }

  assert {
    condition     = output.external_secret_manifest == <<EOF
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: platform
spec:
  refreshInterval: "15m"
  secretStoreRef:
    name: secret-store
    kind: SecretStore
  data:
    - secretKey: username
      remoteRef:
        key: postgres/test-postgres-secrets
        property: username
    - secretKey: password
      remoteRef:
        key: postgres/test-postgres-secrets
        property: password
    - secretKey: host
      remoteRef:
        key: postgres/test-postgres-secrets
        property: host
EOF
    error_message = "The external_secret_manifest output should contain the ExternalSecret manifest"
  }
}
