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

run "state_outputs" {
  command = apply

  variables {
    state_bucket_name = "test-bucket-default"
  }

  assert {
    condition     = module.object_storage.bucket_name == "test-bucket-default"
    error_message = "Bucket name does not match expected value"
  }

  assert {
    condition     = output.access_key != null && output.access_key != ""
    error_message = "Access key should be generated"
  }

  assert {
    condition     = output.secret_access_key != null && output.secret_access_key != ""
    error_message = "Secret access key should be generated"
  }

  assert {
    condition     = output.backend_file == "terraform {\n  backend \"s3\" {\n    bucket       = \"test-bucket-default\"\n    key          = \"tfstate-backend\"\n    use_lockfile = true\n    endpoints = {\n      s3 = \"https://object.storage.eu01.onstackit.cloud\"\n    }\n    region                      = \"eu01\"\n    skip_credentials_validation = true\n    skip_region_validation      = true\n    skip_s3_checksum            = true\n    skip_requesting_account_id  = true\n  }\n}\n"
    error_message = "Backend file content is incorrect"
  }
  assert {
    condition     = nonsensitive(output.envrc_file) == "export AWS_ACCESS_KEY_ID=\"mock-access-key\"\nexport AWS_SECRET_ACCESS_KEY=\"mock-secret-key\"\n"
    error_message = "Envrc file content is incorrect"

  }
}

