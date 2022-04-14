resource "tls_private_key" "deploy_key" {
  algorithm = "ED25519"
}

resource "github_actions_environment_secret" "private_deploy_key" {
  repository      = var.deploying_repository
  environment     = var.environment
  secret_name     = var.deploying_repository_private_key_secret_name
  plaintext_value = tls_private_key.deploy_key.private_key_openssh
}

resource "github_repository_deploy_key" "public_deploy_key" {
  repository = var.infra_repository
  title      = var.environment
  key        = tls_private_key.deploy_key.public_key_openssh
  read_only  = "false"
}
