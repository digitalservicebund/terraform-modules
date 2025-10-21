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

variables {
  project_id = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
}

# Test 1: Default configuration with single credential
run "default_configuration" {
  command = apply

  variables {
    bucket_name = "test-bucket-default"
  }

  assert {
    condition     = stackit_objectstorage_bucket.state_bucket.name == "test-bucket-default"
    error_message = "Bucket name does not match expected value"
  }

  assert {
    condition     = stackit_objectstorage_credentials_group.credentials_group.name == "test-bucket-default-cg"
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
    bucket_name       = "test-bucket-multi"
    credentials_names = ["credential-1", "credential-2", "credential-3"]
  }

  assert {
    condition     = length(keys(stackit_objectstorage_credential.credential)) == 3
    error_message = "Should create exactly three credentials"
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
    condition     = contains(keys(stackit_objectstorage_credential.credential), "credential-3")
    error_message = "credential-3 should exist"
  }

  assert {
    condition     = length(keys(output.credentials)) == 3
    error_message = "Output should contain all three credentials"
  }
}

# Test 3: Maximum bucket name length (29 characters)
run "max_bucket_name_length" {
  command = apply

  variables {
    bucket_name = "abcdefghijklmnopqrstuvwxyz123" # 29 characters
  }

  assert {
    condition     = stackit_objectstorage_bucket.state_bucket.name == "abcdefghijklmnopqrstuvwxyz123"
    error_message = "Should accept 29 character bucket name"
  }

  assert {
    condition     = length(stackit_objectstorage_credentials_group.credentials_group.name) <= 32
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
