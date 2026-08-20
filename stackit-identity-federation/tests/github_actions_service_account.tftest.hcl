mock_provider "stackit" {
  mock_resource "stackit_service_account" {
    defaults = {
      service_account_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
      email              = "sa01@sa.stackit.cloud"
      id                 = "sa01,sa01@sa.stackit.cloud"
    }
  }

  mock_resource "stackit_authorization_project_role_assignment" {
    defaults = {
      id = "resource_id,role,subject"
    }
  }

  mock_resource "stackit_authorization_organization_custom_role" {
    defaults = {
      role_id = "99999999-8888-7777-6666-555555555555"
      id      = "resource_id,99999999-8888-7777-6666-555555555555"
    }
  }

  mock_resource "stackit_service_account_federated_identity_provider" {
    defaults = {
      federation_id = "11111111-2222-3333-4444-555555555555"
      id            = "project_id,sa01@sa.stackit.cloud,11111111-2222-3333-4444-555555555555"
    }
  }
}

variables {
  project_id        = "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
  name              = "gh-actions-terraform"
  roles             = ["editor"]
  github_repository = "digitalservicebund/terraform-modules"
}

run "name_must_not_be_empty" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [
    var.name,
  ]
}

run "name_must_not_contain_uppercase" {
  command = plan

  variables {
    name = "My-Service-Account"
  }

  expect_failures = [
    var.name,
  ]
}

run "roles_and_permissions_must_not_both_be_empty" {
  command = plan

  variables {
    roles       = []
    permissions = []
  }

  expect_failures = [
    var.permissions,
  ]
}

run "permissions_only_is_valid" {
  command = apply

  variables {
    roles       = []
    permissions = ["iam.subject.get"]
  }

  assert {
    condition     = length(stackit_authorization_organization_custom_role.this) == 1
    error_message = "A custom role should be created when permissions are supplied"
  }

  assert {
    condition     = stackit_authorization_organization_custom_role.this[0].name == "service-account.gh-actions-terraform"
    error_message = "Custom role name should be derived from the service account name"
  }

  assert {
    condition     = stackit_authorization_organization_custom_role.this[0].permissions == tolist(["iam.subject.get"])
    error_message = "Custom role should contain the supplied permissions"
  }

  assert {
    condition     = stackit_authorization_organization_custom_role.this[0].resource_id == "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    error_message = "Custom role should default to the project_id as resource_id"
  }

  assert {
    condition     = keys(stackit_authorization_project_role_assignment.this) == ["service-account.gh-actions-terraform"]
    error_message = "Only the generated custom role should be assigned"
  }
}

run "roles_only_creates_no_custom_role" {
  command = apply

  assert {
    condition     = length(stackit_authorization_organization_custom_role.this) == 0
    error_message = "No custom role should be created when no permissions are supplied"
  }

  assert {
    condition     = output.custom_role_name == null
    error_message = "custom_role_name output should be null when no permissions are supplied"
  }
}

run "roles_and_permissions_are_combined" {
  command = apply

  variables {
    roles                   = ["editor"]
    permissions             = ["iam.subject.get"]
    resource_id             = "22222222-3333-4444-5555-666666666666"
    custom_role_description = "Least privilege role"
  }

  assert {
    condition = toset(keys(stackit_authorization_project_role_assignment.this)) == toset([
      "editor",
      "service-account.gh-actions-terraform",
    ])
    error_message = "Both the supplied roles and the generated custom role should be assigned"
  }

  assert {
    condition     = stackit_authorization_organization_custom_role.this[0].resource_id == "22222222-3333-4444-5555-666666666666"
    error_message = "Custom role should use the overridden resource_id"
  }

  assert {
    condition     = stackit_authorization_organization_custom_role.this[0].description == "Least privilege role"
    error_message = "Custom role should use the supplied description"
  }
}

run "github_repository_must_be_org_slash_repo" {
  command = plan

  variables {
    github_repository = "not-a-valid-repo"
  }

  expect_failures = [
    var.github_repository,
  ]
}

run "github_subjects_must_match_allowed_patterns" {
  command = plan

  variables {
    github_subjects = ["ref:refs/does-not-match"]
  }

  expect_failures = [
    var.github_subjects,
  ]
}

run "github_subjects_must_not_be_empty" {
  command = plan

  variables {
    github_subjects = []
  }

  expect_failures = [
    var.github_subjects,
  ]
}

run "basic_config" {
  command = apply

  assert {
    condition     = stackit_service_account.this.name == "gh-actions-terraform"
    error_message = "Service account name does not match expected value"
  }

  assert {
    condition     = stackit_authorization_project_role_assignment.this["editor"].role == "editor"
    error_message = "Role assignment does not have the expected role"
  }

  assert {
    condition     = stackit_authorization_project_role_assignment.this["editor"].resource_id == "aeac146a-97d6-4677-91eb-6ab5f8b0c202"
    error_message = "Role assignment should default to the project_id as resource_id"
  }

  assert {
    condition     = stackit_service_account_federated_identity_provider.github_actions["ref:refs/heads/main"].issuer == "https://token.actions.githubusercontent.com"
    error_message = "Federation should default to GitHub's public OIDC issuer"
  }

  assert {
    condition = contains(
      stackit_service_account_federated_identity_provider.github_actions["ref:refs/heads/main"].assertions,
      { item = "aud", operator = "equals", value = "sts.accounts.stackit.cloud" }
    )
    error_message = "Federation must always assert the audience claim"
  }

  assert {
    condition = contains(
      stackit_service_account_federated_identity_provider.github_actions["ref:refs/heads/main"].assertions,
      { item = "sub", operator = "equals", value = "repo:digitalservicebund/terraform-modules:ref:refs/heads/main" }
    )
    error_message = "Federation must assert the expected GitHub Actions subject claim"
  }
}

run "multiple_subjects_create_separate_federations" {
  command = apply

  variables {
    github_subjects = [
      "ref:refs/heads/main",
      "environment:production",
    ]
  }

  assert {
    condition     = length(stackit_service_account_federated_identity_provider.github_actions) == 2
    error_message = "Expected one federation per github_subjects entry"
  }

  assert {
    condition = contains(
      stackit_service_account_federated_identity_provider.github_actions["environment:production"].assertions,
      { item = "sub", operator = "equals", value = "repo:digitalservicebund/terraform-modules:environment:production" }
    )
    error_message = "Environment based federation must assert the expected subject claim"
  }
}

run "additional_assertions_are_appended" {
  command = apply

  variables {
    additional_assertions = [
      {
        item     = "repository_owner"
        operator = "equals"
        value    = "digitalservicebund"
      }
    ]
  }

  assert {
    condition = contains(
      stackit_service_account_federated_identity_provider.github_actions["ref:refs/heads/main"].assertions,
      { item = "repository_owner", operator = "equals", value = "digitalservicebund" }
    )
    error_message = "Additional assertions should be appended to the federation"
  }
}

run "resource_id_can_be_overridden" {
  command = apply

  variables {
    resource_id = "11111111-2222-3333-4444-555555555555"
  }

  assert {
    condition     = stackit_authorization_project_role_assignment.this["editor"].resource_id == "11111111-2222-3333-4444-555555555555"
    error_message = "Role assignment should use the overridden resource_id"
  }
}
