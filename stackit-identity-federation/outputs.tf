output "service_account_email" {
  value       = stackit_service_account.this.email
  description = "Email of the created service account"
}

output "service_account_id" {
  value       = stackit_service_account.this.service_account_id
  description = "Internal UUID of the created service account"
}

output "role_assignments" {
  value       = { for role, assignment in stackit_authorization_project_role_assignment.this : role => assignment.id }
  description = "Map of role to the ID of the role assignment resource"
}

output "github_actions_federations" {
  value = {
    for subject_claim, federation in stackit_service_account_federated_identity_provider.github_actions :
    subject_claim => {
      federation_id = federation.federation_id
      subject       = local.github_federations[subject_claim].subject
    }
  }
  description = "Map of the configured github_subjects entries to their federation ID and the resulting full GitHub Actions OIDC subject claim"
}
