mock_provider "onepassword" {
  mock_resource "onepassword_vault" {
    defaults = {
      uuid = "employee-vault-123"
      name = "Employee"
    }
  }

  mock_resource "onepassword_item" {
    defaults = {
    }
  }
}

run "default_configuration" {
  command = apply

  variables {
    state_bucket_name   = "test-bucket"
    access_key          = "mock-access-key"
    secret_access_key   = "mock-secret-key"
  }

  assert {
    condition     = onepassword_item.bucket_credentials.title == "test-bucket credentials"
    error_message = "onepassword item title incorrect"
  }

  assert {
    condition     = strcontains(nonsensitive(output.envrc_file), "op://Employee/test-bucket credentials/ACCESS_KEY_ID")
    error_message = "envrc file missing ACCESS_KEY_ID reference"
  }

  assert {
    condition     = strcontains(nonsensitive(output.envrc_file), "op://Employee/test-bucket credentials/SECRET_ACCESS_KEY")
    error_message = "envrc file missing SECRET_ACCESS_KEY reference"
  }

  assert {
    condition     = strcontains(nonsensitive(output.envrc_file), "STACKIT_SERVICE_ACCOUNT_KEY")
    error_message = "envrc file missing STACKIT_SERVICE_ACCOUNT_KEY"
  }
}

