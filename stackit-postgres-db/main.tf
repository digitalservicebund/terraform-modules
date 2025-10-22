resource "stackit_postgresflex_instance" "this" {
  project_id      = var.project_id
  name            = var.name
  acl             = var.acls
  backup_schedule = var.backup_schedule
  flavor = {
    cpu = var.cpu
    ram = var.memory
  }
  replicas = var.replicas
  storage = {
    class = var.disk_type
    size  = var.disk_size
  }
  version = var.engine_version
}

resource "stackit_postgresflex_database" "database" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.this.instance_id
  name        = var.name
  owner       = stackit_postgresflex_user.user.username
}

resource "stackit_postgresflex_user" "user" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.this.instance_id
  roles       = ["login"]
  username    = var.name
}

resource "vault_kv_secret_v2" "postgres_credentials" {
  count = var.manage_user_password ? 1 : 0
  mount = var.secret_manager_instance_id
  name  = "postgres/${stackit_postgresflex_user.user.username}"
  data_json = jsonencode({
    username = stackit_postgresflex_user.user.username
    password = stackit_postgresflex_user.user.password
    host     = stackit_postgresflex_user.user.host
  })
}
