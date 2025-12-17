locals {
  # If database_names is empty, default to a set containing just the instance name.
  # Otherwise, use the provided set.
  databases = length(var.database_names) == 0 ? toset([var.name]) : var.database_names
  # Create the admin user with the name of the instance if not set explicitly
  admin_user = coalesce(var.admin_name, var.name)
}

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

resource "stackit_postgresflex_user" "admin" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.this.instance_id
  roles       = ["login", "createdb"]
  username    = local.admin_user
}

resource "stackit_postgresflex_database" "database" {
  for_each = local.databases # Simple set iteration

  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.this.instance_id
  name        = each.key
  owner       = stackit_postgresflex_user.admin.username
}

resource "stackit_postgresflex_user" "user" {
  for_each = var.user_names # Simple set iteration

  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.this.instance_id
  roles       = ["login"]
  username    = each.key
}


resource "vault_kv_secret_v2" "postgres_admin_credentials" {
  # Create only if enabled
  count = var.manage_user_password ? 1 : 0

  mount = var.secret_manager_instance_id
  name  = "postgres/${stackit_postgresflex_user.admin.username}"

  data_json = jsonencode({
    username = stackit_postgresflex_user.admin.username
    password = stackit_postgresflex_user.admin.password
    host     = stackit_postgresflex_user.admin.host
  })
}

resource "vault_kv_secret_v2" "postgres_user_credentials" {
  # Loop over users only if enabled
  for_each = var.manage_user_password ? var.user_names : []

  mount = var.secret_manager_instance_id
  name  = "postgres/${stackit_postgresflex_user.user[each.key].username}"

  data_json = jsonencode({
    username = stackit_postgresflex_user.user[each.key].username
    password = stackit_postgresflex_user.user[each.key].password
    host     = stackit_postgresflex_user.user[each.key].host
  })
}

resource "local_file" "external_secret_manifest" {
  count = var.manage_user_password ? 1 : 0

  lifecycle {
    precondition {
      # Only create the file if manage_user_password is set (otherwise the resource would not be created at all)
      # and error out if the filename was not provided.
      condition     = var.external_secret_manifest != null
      error_message = "You enabled 'manage_user_password' but did not provide a 'manifest_filename'."
    }
  }

  filename = var.external_secret_manifest

  content = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "database-credentials"
      namespace = var.kubernetes_namespace
    }
    spec = {
      refreshInterval = "15m"
      secretStoreRef = {
        name = "secret-store"
        kind = "SecretStore"
      }
      data = concat(
        [
          {
            secretKey = "${local.admin_user}_user"
            remoteRef = { key = "postgres/${local.admin_user}", property = "username" }
          },
          {
            secretKey = "${local.admin_user}_password"
            remoteRef = { key = "postgres/${local.admin_user}", property = "password" }
          }
        ],
        flatten([
          for user in var.user_names : [
            {
              secretKey = "${user}_user"
              remoteRef = { key = "postgres/${user}", property = "username" }
            },
            {
              secretKey = "${user}_password"
              remoteRef = { key = "postgres/${user}", property = "password" }
            }
          ]
        ])
      )
    }
  })
}

resource "local_file" "config_map_manifest" {
  count = var.config_map_manifest != null ? 1 : 0

  filename = var.config_map_manifest

  content = join("\n---\n", [
    for db_name in local.databases : yamlencode({
      apiVersion = "v1"
      kind       = "ConfigMap"
      metadata = {
        name      = "database-config-${db_name}"
        namespace = var.kubernetes_namespace
      }
      data = {
        database = {
          database = db_name
          host     = stackit_postgresflex_user.admin.host
          port     = tostring(stackit_postgresflex_user.admin.port)
        }
      }
    })
  ])
}