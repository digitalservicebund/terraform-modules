resource "github_repository_environment" "environment" {
  repository  = var.repository
  environment = var.environment
}