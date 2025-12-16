mock_provider "vault" {}

variables {
  secret_manager_instance_id = "test-mount"
  vault_name                 = "test-vault"
  user                       = "test-user"
  manifest_file              = "test-output.yaml"
  manifest_name              = "test-secret-name"
  kubernetes_namespace       = "test-namespace"
}


run "create_credentials" {
  command = apply

  assert {
    condition     = length(random_password.password.result) == 32
    error_message = "Password length must be exactly 32 characters."
  }

  assert {
    condition     = can(regex("^[~!@#%^*\\-_=+?a-zA-Z0-9]+$", random_password.password.result))
    error_message = "Password contains invalid characters."
  }

  assert {
    condition     = vault_kv_secret_v2.credentials.name == "test-vault/test-user"
    error_message = "Vault secret path (name) is constructed incorrectly."
  }

  assert {
    condition     = yamldecode(local_file.external_secret_manifest.content).kind == "ExternalSecret"
    error_message = "Generated YAML 'kind' is not 'ExternalSecret'."
  }

  assert {
    condition     = yamldecode(local_file.external_secret_manifest.content).metadata.namespace == "test-namespace"
    error_message = "Namespace in YAML does not match the input variable."
  }

  assert {
    condition     = yamldecode(local_file.external_secret_manifest.content).spec.data[0].remoteRef.key == "test-vault/test-user"
    error_message = "RemoteRef Key in YAML is incorrect."
  }
}