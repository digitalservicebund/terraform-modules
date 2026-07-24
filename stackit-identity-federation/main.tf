locals {
  resource_id = coalesce(var.resource_id, var.project_id)

  # One narrowly scoped federated identity provider per allowed GitHub Actions subject,
  # so that access can be restricted per branch, tag, environment or pull_request.
  github_federations = {
    for subject_claim in var.github_subjects :
    subject_claim => {
      name    = substr(replace(lower("${var.federation_name_prefix}-${subject_claim}"), "/[^a-z0-9-]+/", "-"), 0, 63)
      subject = "repo:${var.github_repository}:${subject_claim}"
    }
  }
}

resource "stackit_service_account" "this" {
  project_id = var.project_id
  name       = var.name
}

resource "stackit_authorization_project_role_assignment" "this" {
  for_each = toset(var.roles)

  resource_id = local.resource_id
  role        = each.value
  subject     = stackit_service_account.this.email
}

resource "stackit_service_account_federated_identity_provider" "github_actions" {
  for_each = local.github_federations

  project_id            = var.project_id
  service_account_email = stackit_service_account.this.email
  name                  = each.value.name
  issuer                = var.issuer

  # The audience assertion is always enforced for security reasons, in addition
  # to the subject assertion scoping the federation to a single GitHub Actions
  # trigger (branch, tag, environment or pull_request).
  assertions = concat(
    [
      {
        item     = "aud"
        operator = "equals"
        value    = "sts.accounts.stackit.cloud"
      },
      {
        item     = "sub"
        operator = "equals"
        value    = each.value.subject
      },
    ],
    var.additional_assertions
  )
}
