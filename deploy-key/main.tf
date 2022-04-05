data "local_sensitive_file" "private_key" {
  filename = var.key_file_name
  depends_on = [
    null_resource.generate_key
  ]
}

data "local_file" "public_key" {
  filename = "${var.key_file_name}.pub"
  depends_on = [
    null_resource.generate_key
  ]
}

resource "null_resource" "generate_key" {
  provisioner "local-exec" {
    command = "ssh-keygen -t ed25519 -a 100 -f ./${var.key_file_name} -q -N '' -C ''"
  }
}

resource "github_actions_environment_secret" "private_deploy_key" {
  repository      = var.deploying_repository
  environment     = var.environment
  secret_name     = var.deploying_repository_private_key_secret_name
  plaintext_value = data.local_sensitive_file.private_key.content
}

resource "github_repository_deploy_key" "public_deploy_key" {
  repository = var.infra_repository
  title      = var.environment
  key        = data.local_file.public_key.content
  read_only  = "false"
}
