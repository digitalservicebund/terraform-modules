resource "github_repository_environment" "environment" {
  repository  = var.repository
  environment = var.environment

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_deployment_branch_policy" "this" {
  repository       = var.repository
  environment_name = var.environment

  name = var.branch_name_pattern
}