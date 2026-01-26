mock_provider "stackit" {
  mock_resource "stackit_objectstorage_bucket" {
    defaults = {
      id         = "bucket-123"
      project_id = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    }
  }

  mock_resource "stackit_objectstorage_credentials_group" {
    defaults = {
      credentials_group_id = "12168432-2b8f-44de-8514-11bd9f9ad8b6"
      project_id           = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
      urn                  = "urn:stackit:objectstorage:credentialsgroup:12168432-2b8f-44de-8514-11bd9f9ad8b6"
    }
  }

  mock_resource "stackit_objectstorage_credential" {
    defaults = {
      access_key        = "mock-access-key"
      secret_access_key = "mock-secret-key"
      project_id        = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    }
  }
}

mock_provider "vault" {
  mock_resource "vault_kv_secret_v2" {
    defaults = {
      mount = "secret-mount"
      name  = "object-storage/mock-bucket"
    }
  }
}
mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Statement\":[],\"Version\":\"2012-10-17\"}"
    }
  }
}

variables {
  project_id                     = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
  external_secret_manifest       = "secret.yaml"
  terraform_credentials_group_id = null
}

# Test 1: Default configuration with only terraform credential
run "default_configuration" {
  command = apply

  variables {
    bucket_name = "test-bucket-default"
  }

  assert {
    condition     = stackit_objectstorage_bucket.bucket.name == "test-bucket-default"
    error_message = "Bucket name does not match expected value"
  }

  assert {
    condition     = stackit_objectstorage_credentials_group.terraform_credentials_group[0].name == "test-bucket-default-cg"
    error_message = "Credentials group name does not match expected format"
  }

  assert {
    condition     = length(keys(stackit_objectstorage_credential.credential)) == 1
    error_message = "Should create exactly one credential by default"
  }

  assert {
    condition     = contains(keys(stackit_objectstorage_credential.credential), "default")
    error_message = "Default credential should exist"
  }

  assert {
    condition     = output.credentials["default"].access_key != null && output.credentials["default"].access_key != ""
    error_message = "Access key should be generated"
  }

  assert {
    condition     = output.credentials["default"].secret_access_key != null && output.credentials["default"].secret_access_key != ""
    error_message = "Secret access key should be generated"
  }
}

# Test 2: Multiple credentials
run "multiple_credentials" {
  command = apply

  variables {
    bucket_name = "test-bucket-multi"
    credentials = {
      "credential-1" = "read-only"
      "credential-2" = "superuser"
    }
  }

  assert {
    condition     = length(keys(stackit_objectstorage_credential.credential)) == 2
    error_message = "Should create exactly two credentials"
  }

  assert {
    condition     = contains(keys(stackit_objectstorage_credential.credential), "credential-1")
    error_message = "credential-1 should exist"
  }

  assert {
    condition     = contains(keys(stackit_objectstorage_credential.credential), "credential-2")
    error_message = "credential-2 should exist"
  }

  assert {
    condition     = length(keys(output.credentials)) == 2
    error_message = "Output should contain all two credentials"
  }
}

# Test 3: Maximum bucket name length (29 characters)
run "max_bucket_name_length" {
  command = apply

  variables {
    bucket_name = "abcdefghijklmnopqrstuvwxyz123" # 29 characters
  }

  assert {
    condition     = stackit_objectstorage_bucket.bucket.name == "abcdefghijklmnopqrstuvwxyz123"
    error_message = "Should accept 29 character bucket name"
  }

  assert {
    condition     = length(stackit_objectstorage_credentials_group.terraform_credentials_group[0].name) <= 32
    error_message = "Credentials group name should not exceed 32 characters"
  }
}

# Test 4: Bucket name too long (should fail validation)
run "bucket_name_too_long" {
  command = plan

  variables {
    bucket_name = "abcdefghijklmnopqrstuvwxyz1234" # 30 characters
  }

  expect_failures = [
    var.bucket_name,
  ]
}

# Test 5: Vault integration and External Secret manifest generation
run "vault_integration" {
  command = apply

  variables {
    bucket_name                = "test-bucket-vault"
    manage_credentials         = true
    secret_manager_instance_id = "kv-mount"
    kubernetes_namespace       = "production-ns"
    credentials                = { rw = "read-write", ro = "read-only" }
  }

  # 1. Verify the Vault secret resource is created
  assert {
    condition     = length(vault_kv_secret_v2.bucket_credentials) == 2
    error_message = "Should create exactly one Vault secret when manage_credentials is true"
  }

  assert {
    condition     = vault_kv_secret_v2.bucket_credentials["rw"].name == "object-storage/test-bucket-vault/rw"
    error_message = "Vault secret path/name does not match expected format"
  }

  # 2. Verify the Credentials Output is hidden/empty
  assert {
    condition     = length(nonsensitive(output.credentials)) == 0
    error_message = "Output credentials should be empty when managed by Vault"
  }

  # 3. Verify External Secret Manifest Content
  assert {
    condition     = yamldecode(split("\n---\n", local_file.external_secret_manifest[0].content)[0]).spec.data[0].secretKey == "access_key"
    error_message = "The first data item secretKey should be access_key"
  }

  assert {
    condition     = yamldecode(split("\n---\n", local_file.external_secret_manifest[0].content)[0]).spec.data[0].remoteRef.key == "object-storage/test-bucket-vault/ro"
    error_message = "The remoteRef key was not generated correctly"
  }

  assert {
    condition     = yamldecode(split("\n---\n", local_file.external_secret_manifest[0].content)[0]).spec.data[1].secretKey == "secret_access_key"
    error_message = "The first data item secretKey should be access_key"
  }

  assert {
    condition     = yamldecode(split("\n---\n", local_file.external_secret_manifest[0].content)[0]).spec.data[1].remoteRef.key == "object-storage/test-bucket-vault/ro"
    error_message = "The remoteRef key was not generated correctly"
  }

  assert {
    condition     = yamldecode(split("\n---\n", local_file.external_secret_manifest[0].content)[1]).spec.data[0].secretKey == "access_key"
    error_message = "The first data item secretKey should be access_key"
  }

  assert {
    condition     = yamldecode(split("\n---\n", local_file.external_secret_manifest[0].content)[1]).spec.data[0].remoteRef.key == "object-storage/test-bucket-vault/rw"
    error_message = "The remoteRef key was not generated correctly"
  }

  assert {
    condition     = yamldecode(split("\n---\n", local_file.external_secret_manifest[0].content)[1]).spec.data[1].secretKey == "secret_access_key"
    error_message = "The first data item secretKey should be access_key"
  }

  assert {
    condition     = yamldecode(split("\n---\n", local_file.external_secret_manifest[0].content)[1]).spec.data[1].remoteRef.key == "object-storage/test-bucket-vault/rw"
    error_message = "The remoteRef key was not generated correctly"
  }
}

run "external_secret_manifest_missing" {
  command = plan

  variables {
    bucket_name                = "fail-test"
    manage_credentials         = true
    external_secret_manifest   = null
    kubernetes_namespace       = "namespace"
    secret_manager_instance_id = "kv-mount"

  }

  # We want to manage the secrets externally but forgot to specify the K8s manifest file path to glue things together
  expect_failures = [
    local_file.external_secret_manifest
  ]
}

run "kubernetes_namespace_missing" {
  command = plan

  variables {
    bucket_name                = "fail-test"
    manage_credentials         = true
    external_secret_manifest   = "secret.yaml"
    kubernetes_namespace       = null
    secret_manager_instance_id = "kv-mount"

  }

  # We want to manage the secrets externally but forgot to specify the K8s manifest file path to glue things together
  expect_failures = [
    local_file.external_secret_manifest,
  ]
}

# Test: Default lifecycle does not create lifecycle resource
run "lifecycle_disabled_by_default" {
  command = plan

  variables {
    bucket_name    = "test-lifecycle-off"
    lifecycle_days = null
  }

  assert {
    condition     = !can(aws_s3_bucket_lifecycle_configuration.bucket_lifecycle[0])
    error_message = "Lifecycle configuration should not be created when lifecycle_days is 0"
  }
}

# Test: Positive Lifecycle value creates a lifecycle resource
run "lifecycle_enabled" {
  command = plan

  variables {
    bucket_name    = "test-lifecycle-on"
    lifecycle_days = 30
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.bucket_lifecycle) == 1
    error_message = "Lifecycle configuration should be created when days > 0"
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.bucket_lifecycle[0].rule[0].expiration[0].days == 30
    error_message = "Lifecycle expiration days do not match expected value"
  }
}

# Test: Validierung schlägt bei negativen Zahlen fehl
run "lifecycle_invalid_value" {
  command = plan

  variables {
    bucket_name    = "test-lifecycle-fail"
    lifecycle_days = -5
  }

  expect_failures = [
    var.lifecycle_days,
  ]
}

run "disable_manifest_creation" {
  command = apply

  variables {
    bucket_name                = "fail-test"
    manage_credentials         = true
    secret_manager_instance_id = "kv-mount"
    enable_manifest_creation   = false
  }
  assert {
    condition     = length(local_file.external_secret_manifest) == 0
    error_message = "External Secret manifest should not be created when enable_manifest_creation is false"
  }
}
