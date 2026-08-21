locals {
  resource_id = coalesce(var.resource_id, var.project_id)

  # A dedicated custom role bundling var.permissions, so the service account can be
  # granted least privilege instead of a broad predefined role.
  create_custom_role = length(var.permissions) > 0
  custom_role_name   = "service-account.${var.name}"

  # The name is derived from var.name instead of the resource attribute, so that it is
  # known at plan time and can be used as a for_each key.
  assigned_roles = concat(
    var.roles,
    local.create_custom_role ? [local.custom_role_name] : []
  )

  # One narrowly scoped federated identity provider per allowed GitHub Actions subject,
  # so that access can be restricted per branch, tag, environment or pull_request.
  github_federations = {
    for subject_claim in var.github_subjects :
    subject_claim => {
      name    = substr(replace(lower("${var.federation_name_prefix}-${subject_claim}"), "/[^a-z0-9-]+/", "-"), 0, 63)
      subject = "${startswith(var.github_repository, "repo:") ? "" : "repo:"}${var.github_repository}:${subject_claim}"
    }
  }
}

resource "stackit_service_account" "this" {
  project_id = var.project_id
  name       = var.name
}

resource "stackit_authorization_organization_custom_role" "this" {
  count = local.create_custom_role ? 1 : 0

  resource_id = local.resource_id
  name        = local.custom_role_name
  description = coalesce(var.custom_role_description, "Custom role for service account ${var.name}")
  permissions = var.permissions
}

resource "stackit_authorization_project_role_assignment" "this" {
  for_each = toset(local.assigned_roles)

  resource_id = local.resource_id
  role        = each.value
  subject     = stackit_service_account.this.email

  depends_on = [stackit_authorization_organization_custom_role.this]
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
