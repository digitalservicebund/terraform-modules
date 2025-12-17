mock_provider "stackit" {
  mock_resource "stackit_postgresflex_instance" {
    defaults = {
      instance_id = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    }
  }
  mock_resource "stackit_postgresflex_user" {
    defaults = {
      password = "password"
      host     = "postgres.stackit.internal"
    }
  }
  mock_resource "stackit_postgresflex_database" {}
}

mock_provider "vault" {
  mock_resource "vault_kv_secret_v2" {}
}

variables {
  project_id     = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
  name           = "test-postgres"
  cpu            = 2
  memory         = 4
  engine_version = "17"
  disk_size      = 10
  acls           = ["10.0.0.0/16"]
  admin_name     = "root"

  kubernetes_namespace = "namespace"
}

# --- Test 1: Basic Creation ---
run "basic_creation" {
  command = apply

  variables {
    database_names = ["neuris", "metabase"]
    user_names     = ["migration", "search"]

    manage_user_password = false
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
    condition     = stackit_postgresflex_user.admin.username == "root"
    error_message = "Admin username should be 'root'"
  }

  assert {
    condition     = stackit_postgresflex_user.user["migration"].username == "migration"
    error_message = "Migration user should exist"
  }

  assert {
    condition     = stackit_postgresflex_database.database["neuris"].owner == stackit_postgresflex_user.admin.username
    error_message = "The database owner should be the user created by this module"
  }

  assert {
    condition     = output.address == "postgres.stackit.internal"
    error_message = "The address output should be set correctly"
  }

  assert {
    condition     = nonsensitive(output.credentials["root"]) == "password"
    error_message = "Admin user and password should be available"
  }

  assert {
    condition     = nonsensitive(output.credentials["migration"]) == "password"
    error_message = "User and password should be available"
  }

}

run "secrets_and_manifest" {
  command = apply

  variables {
    name = "test-secrets"

    database_names = ["neuris"]
    user_names     = ["migration"]

    manage_user_password       = true
    secret_manager_instance_id = "mock-vault"

    external_secret_manifest = "output.yaml"
  }

  assert {
    condition = nonsensitive(vault_kv_secret_v2.postgres_admin_credentials[0].data_json) == jsonencode({
      username = "root"
      password = "password"
      host     = "postgres.stackit.internal"
    })
    error_message = "Vault secret should contain the correct database credentials"
  }

  assert {
    condition = nonsensitive(vault_kv_secret_v2.postgres_user_credentials["migration"].data_json) == jsonencode({
      username = "migration"
      password = "password"
      host     = "postgres.stackit.internal"
    })
    error_message = "Vault secret should contain the correct user credentials"
  }

  assert {
    condition     = contains(output.secret_manager_secret_names, "postgres/root")
    error_message = "Secret names list should contain admin secret"
  }

  assert {
    condition     = contains(output.secret_manager_secret_names, "postgres/migration")
    error_message = "Secret names list should contain migration secret"
  }

  assert {
    condition     = contains(yamldecode(local_file.external_secret_manifest[0].content).spec.data.*.secretKey, "root_user")
    error_message = "Manifest missing root_user"
  }

  assert {
    condition     = contains(yamldecode(local_file.external_secret_manifest[0].content).spec.data.*.secretKey, "migration_user")
    error_message = "Manifest missing migration_user"
  }
}

run "external_secret_manifest_missing" {
  command = plan

  variables {
    name                     = "fail-test"
    manage_user_password     = true
    external_secret_manifest = null
  }

  # We want to mnanage the secrets externally but forgot to specify the K8s manifest file path to glue things together
  expect_failures = [
    local_file.external_secret_manifest
  ]
}

run "config_map_manifest" {
  command = apply

  variables {
    database_names = ["neuris", "metabase"]
    user_names     = ["migration", "search"]

    manage_user_password = false
    config_map_manifest  = "config.yaml"
  }
  assert {
    condition     = yamldecode(split("\n---\n", local_file.config_map_manifest[0].content)[0]).metadata.name == "database-config-metabase"
    error_message = "First ConfigMap should be for 'metabase'"
  }

  assert {
    condition     = yamldecode(split("\n---\n", local_file.config_map_manifest[0].content)[1]).metadata.name == "database-config-neuris"
    error_message = "First ConfigMap should be for 'neuris'"
  }
}

run "kubernetes_namespace_missing" {
  command = plan

  variables {
    name                     = "fail-test"
    manage_user_password     = true
    external_secret_manifest = "secret.yaml"
    config_map_manifest      = "config.yaml"
    kubernetes_namespace     = null
  }

  # We want to mnanage the secrets externally but forgot to specify the K8s manifest file path to glue things together
  expect_failures = [
    local_file.external_secret_manifest,
    local_file.config_map_manifest
  ]
}

