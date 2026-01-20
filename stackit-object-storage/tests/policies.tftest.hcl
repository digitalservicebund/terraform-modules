mock_provider "stackit" {
  mock_resource "stackit_objectstorage_bucket" {
    defaults = {
      id         = "bucket-123"
      project_id = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    }
  }

  mock_resource "stackit_objectstorage_credential" {
    defaults = {
      access_key        = "mock-access-key"
      secret_access_key = "mock-secret-key"
      project_id        = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    }
  }

  mock_data "stackit_objectstorage_credentials_group" {
    defaults = {
      credentials_group_id = "12168432-2b8f-44de-8514-11bd9f9ad8b6"
      project_id           = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
      urn                  = "urn:stackit:objectstorage:credentialsgroup:existing_tf_group"
    }
  }
}

# Mocking the AWS provider to avoid real API calls during testing
# Can't use the mock_provider for aws because it would override the aws_iam_policy_document data source
provider "aws" {
  region     = "us-east-1"
  access_key = "mock_access_key"
  secret_key = "mock_secret_key"

  # specific flags to skip auth and API calls
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

override_resource {
  target = aws_s3_bucket_policy.bucket_policy
}

override_resource {
  target = stackit_objectstorage_credentials_group.terraform_credentials_group
  values = {
    credentials_group_id = "5f2001ad-75b0-46f2-900d-1ab8d39b6a7d"
    urn                  = "urn:stackit:objectstorage:credentialsgroup:terraform"
  }
}
override_resource {
  target = stackit_objectstorage_credentials_group.user_credentials_group["superuser"]
  values = {
    credentials_group_id = "636573b0-f12d-461a-ac55-5078a1bf18f5"
    urn                  = "urn:stackit:objectstorage:credentialsgroup:su"
  }
}
override_resource {
  target = stackit_objectstorage_credentials_group.user_credentials_group["read-write"]
  values = {
    credentials_group_id = "3b5f9bef-9040-4351-817e-c8a0f92eece8"
    urn                  = "urn:stackit:objectstorage:credentialsgroup:rw"
  }
}
override_resource {
  target = stackit_objectstorage_credentials_group.user_credentials_group["read-only"]
  values = {
    credentials_group_id = "2831a53d-dc92-471e-b280-75f2843383f1"
    urn                  = "urn:stackit:objectstorage:credentialsgroup:ro"
  }
}


variables {
  project_id               = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
  external_secret_manifest = "secret.yaml"
}

run "policy_generation" {
  command = apply
  variables {
    bucket_name                    = "test-bucket-default"
    terraform_credentials_group_id = null
    credentials = {
      "credential-1" = "superuser"
      "credential-2" = "read-write"
      "credential-3" = "read-only"
      "credential-4" = "read-only"
    }
  }

  assert {
    condition     = length(keys(stackit_objectstorage_credentials_group.user_credentials_group)) == 3
    error_message = "Should create exactly three credential groups"
  }
  assert {
    condition     = length(keys(stackit_objectstorage_credential.credential)) == 4
    error_message = "Should create exactly four credentials"
  }
  assert {
    condition = (
      jsondecode(data.aws_iam_policy_document.combined_policy.json).Statement[0].Action == "s3:*" &&
      jsondecode(data.aws_iam_policy_document.combined_policy.json).Statement[0].NotPrincipal.AWS == ["urn:stackit:objectstorage:credentialsgroup:terraform", "urn:stackit:objectstorage:credentialsgroup:su", "urn:stackit:objectstorage:credentialsgroup:rw", "urn:stackit:objectstorage:credentialsgroup:ro"]
    )
    error_message = "Policy to restrict access for other credentials groups is incorrect"
  }

  assert {
    condition = (
      jsondecode(data.aws_iam_policy_document.combined_policy.json).Statement[1].Action == ["s3:Restore*", "s3:Put*", "s3:Delete*", "s3:Abort*"] &&
      jsondecode(data.aws_iam_policy_document.combined_policy.json).Statement[1].Principal.AWS == "urn:stackit:objectstorage:credentialsgroup:ro"
    )
    error_message = "Read-only policy is incorrect"
  }

  assert {
    condition = (
      jsondecode(data.aws_iam_policy_document.combined_policy.json).Statement[2].Action == ["s3:PutReplicationConfiguration", "s3:PutLifecycleConfiguration", "s3:PutEncryptionConfiguration", "s3:PutBucketTagging", "s3:PutBucketPolicy", "s3:DeleteBucketPolicy", "s3:DeleteBucket"] &&
      jsondecode(data.aws_iam_policy_document.combined_policy.json).Statement[2].Principal.AWS == "urn:stackit:objectstorage:credentialsgroup:rw"
    )
    error_message = "Read-write policy is incorrect"
  }
}


run "exsting_terraform_credential_group" {
  command = apply

  variables {
    bucket_name                    = "test-bucket-existing-tf-cred"
    terraform_credentials_group_id = "12168432-2b8f-44de-8514-11bd9f9ad8b6"
    credentials                    = { ro = "read-only" }
  }

  assert {
    condition     = stackit_objectstorage_credentials_group.terraform_credentials_group == []
    error_message = "Should not create a new terraform credentials group when an existing ID is provided"
  }

  assert {
    condition     = length(stackit_objectstorage_credential.terraform_credentials) == 0
    error_message = "Should not create terraform credentials when an existing credentials group ID is provided"
  }

  assert {
    condition = (
      jsondecode(data.aws_iam_policy_document.combined_policy.json).Statement[0].Action == "s3:*" &&
      jsondecode(data.aws_iam_policy_document.combined_policy.json).Statement[0].NotPrincipal.AWS == ["urn:stackit:objectstorage:credentialsgroup:ro", "urn:stackit:objectstorage:credentialsgroup:existing_tf_group"]
    )
    error_message = "Policy to restrict access for other credentials groups is incorrect"
  }
}
