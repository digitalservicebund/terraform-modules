resource "stackit_secretsmanager_instance" "this" {
  project_id = var.project_id
  name       = var.name
}

resource "vault_generic_endpoint" "config" {
  path = "${stackit_secretsmanager_instance.this.instance_id}/config"
  data_json = jsonencode({
    "max_versions" : var.max_versions
  })
  disable_delete       = true
  ignore_absent_fields = true
}

resource "stackit_secretsmanager_user" "terraform" {
  project_id    = var.project_id
  description   = "Terraform Provider Access"
  instance_id   = stackit_secretsmanager_instance.this.instance_id
  write_enabled = true
}

resource "stackit_secretsmanager_user" "external_secrets" {
  project_id    = var.project_id
  description   = "Kubernetes ExternalSecretsOperator Access"
  instance_id   = stackit_secretsmanager_instance.this.instance_id
  write_enabled = false
}
