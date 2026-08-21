mock_provider "stackit" {
  mock_resource "stackit_logs_instance" {
    defaults = {
      instance_id     = "a0000000-0000-0000-0000-000000000001"
      project_id      = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
      ingest_otlp_url = "https://logs-otlp.eu01.example.com"
      query_url       = "https://logs-query.eu01.example.com"
      datasource_url  = "https://logs-ds.eu01.example.com"
    }
  }

  mock_resource "stackit_logs_access_token" {
    defaults = {
      access_token_id = "logs-token-abc"
      access_token    = "mock-logs-bearer-token"
    }
  }

  mock_resource "stackit_objectstorage_bucket" {
    defaults = {
      id          = "bucket-456"
      project_id  = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
      object_lock = true
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

  mock_resource "stackit_telemetryrouter_instance" {
    defaults = {
      instance_id = "b0000000-0000-0000-0000-000000000002"
      project_id  = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
      uri         = "https://telemetry-router.eu01.example.com"
    }
  }

  mock_resource "stackit_telemetryrouter_access_token" {
    defaults = {
      access_token_id = "router-token-abc"
      access_token    = "mock-router-access-token"
    }
  }

  mock_resource "stackit_telemetryrouter_destination" {
    defaults = {
      destination_id = "dest-id-001"
      project_id     = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    }
  }

  mock_resource "stackit_telemetrylink" {
    defaults = {
      id            = "organization,11111111-0000-0000-0000-000000000001,eu01"
      resource_type = "organization"
      resource_id   = "11111111-0000-0000-0000-000000000001"
    }
  }

  mock_data "stackit_objectstorage_credentials_group" {
    defaults = {
      credentials_group_id = "existing-cg-id"
      urn                  = "urn:stackit:objectstorage:credentialsgroup:existing-cg-id"
    }
  }
}

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Statement\":[],\"Version\":\"2012-10-17\"}"
    }
  }

  mock_resource "aws_s3_bucket_object_lock_configuration" {
    defaults = {}
  }

  mock_resource "aws_s3_bucket_lifecycle_configuration" {
    defaults = {}
  }

  mock_resource "aws_s3_bucket_policy" {
    defaults = {}
  }
}

variables {
  project_id                     = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
  log_storage_project_id         = "bbbbbbbb-97d6-4677-91eb-6ab5f8b0c202"
  terraform_credentials_group_id = "existing-cg-id"
  name                           = "platform-audit"
  organization_id                = "11111111-0000-0000-0000-000000000001"
}

run "default_configuration" {
  command = apply

  assert {
    condition     = stackit_telemetrylink.organization.resource_type == "organization"
    error_message = "Telemetry link must be organization scoped."
  }


  assert {
    condition     = stackit_logs_instance.this.retention_days == 180
    error_message = "Logs retention should default to 180 days."
  }

  assert {
    condition     = stackit_objectstorage_bucket.audit_logs.name == "platform-audit-bucket"
    error_message = "Bucket name should be derived from the module name."
  }

  # Lifecycle is now created by default (3660 days)
  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.expiration) == 1
    error_message = "Lifecycle configuration should be created by default."
  }
}

run "lifecycle_disabled" {
  command = plan

  variables {
    lifecycle_expiration_days = null
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.expiration) == 0
    error_message = "Lifecycle configuration should not be created when set to null."
  }
}


run "invalid_object_lock_mode" {
  command = plan

  variables {
    object_lock_mode = "READ-ONLY"
  }

  expect_failures = [var.object_lock_mode]
}

run "separated_projects" {
  command = plan

  variables {
    project_id             = "aaaa1111-97d6-4677-91eb-6ab5f8b0c202"
    log_storage_project_id = "bbbb2222-97d6-4677-91eb-6ab5f8b0c202"
  }

  assert {
    condition     = stackit_logs_instance.this.project_id == "bbbb2222-97d6-4677-91eb-6ab5f8b0c202"
    error_message = "Logs instance should be in separate storage project."
  }

  assert {
    condition     = stackit_telemetryrouter_instance.this.project_id == "aaaa1111-97d6-4677-91eb-6ab5f8b0c202"
    error_message = "Router should be in router project."
  }
}

run "single_project_fallback" {
  command = plan

  variables {
    project_id             = "cccc3333-97d6-4677-91eb-6ab5f8b0c202"
    log_storage_project_id = null
  }

  assert {
    condition     = stackit_logs_instance.this.project_id == "cccc3333-97d6-4677-91eb-6ab5f8b0c202"
    error_message = "Logs instance should fallback to project_id when log_storage_project_id is null."
  }

  assert {
    condition     = stackit_objectstorage_bucket.audit_logs.project_id == "cccc3333-97d6-4677-91eb-6ab5f8b0c202"
    error_message = "S3 bucket should fallback to project_id when log_storage_project_id is null."
  }

  assert {
    condition     = stackit_objectstorage_bucket.audit_logs.name == "platform-audit-bucket"
    error_message = "Derived bucket name should remain stable in fallback mode."
  }

  assert {
    condition     = stackit_telemetryrouter_instance.this.project_id == "cccc3333-97d6-4677-91eb-6ab5f8b0c202"
    error_message = "Router should be in project_id."
  }
}
