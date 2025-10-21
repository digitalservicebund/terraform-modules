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

resource "stackit_postgresflex_user" "user" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.this.instance_id
  roles       = ["login"]
  username    = "admin"
}
