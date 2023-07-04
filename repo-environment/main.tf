resource "github_repository_environment" "environment" {
  repository  = var.repository
  environment = var.environment

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}
