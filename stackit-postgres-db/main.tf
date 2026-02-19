locals {
  # If database_names is empty, default to a set containing just the instance name.
  # Otherwise, use the provided set.
  databases      = length(var.database_names) == 0 ? toset([var.name]) : var.database_names
  admin_username = coalesce(try(var.admin_spec.name, null), var.name)
  admin_secret_path = coalesce(
    try(trimspace(var.admin_spec.secret_manager_path), null),
    "postgres/${local.admin_username}"
  )
  user_secret_paths = {
    for k, u in var.user_spec_map :
    k => coalesce(
      try(trimspace(u.secret_manager_path), null),
      "postgres/${u.name}"
    )
  }

  yaml_autocreate_warning = <<-EOT
    ###
    # DO NOT EDIT MANUALLY
    # THIS FILE IS MANAGED BY TERRAFORM
    ###
  EOT
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
  username    = local.admin_username
}

resource "stackit_postgresflex_database" "database" {
  for_each = local.databases # Simple set iteration

  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.this.instance_id
  name        = each.key
  owner       = stackit_postgresflex_user.admin.username
}

resource "stackit_postgresflex_user" "user" {
  for_each = var.user_spec_map

  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.this.instance_id
  roles       = ["login"]
  username    = each.value.name
}

resource "vault_kv_secret_v2" "postgres_admin_credentials" {
  # Create only if enabled
  count = var.manage_user_password ? 1 : 0

  mount = var.secret_manager_instance_id
  name  = local.admin_secret_path

  data_json = jsonencode({
    username = stackit_postgresflex_user.admin.username
    password = stackit_postgresflex_user.admin.password
    host     = stackit_postgresflex_user.admin.host
  })
}

resource "vault_kv_secret_v2" "postgres_user_credentials" {
  for_each = var.manage_user_password ? var.user_spec_map : {}

  mount = var.secret_manager_instance_id
  name  = local.user_secret_paths[each.key]

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
      condition     = var.external_secret_manifest != null && var.kubernetes_namespace != null
      error_message = "You enabled 'manage_user_password' but did not provide 'manifest_filename' and 'kubernetes_namespace'."
    }
  }

  filename = var.external_secret_manifest

  content = format("%s%s", local.yaml_autocreate_warning, yamlencode({
    apiVersion = "external-secrets.io/v1"
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
            secretKey = "${local.admin_username}_user"
            remoteRef = { key = local.admin_secret_path, property = "username" }
          },
          {
            secretKey = "${local.admin_username}_password"
            remoteRef = { key = local.admin_secret_path, property = "password" }
          }
        ],
        flatten([
          for k, u in var.user_spec_map : [
            {
              secretKey = "${u.name}_user"
              remoteRef = { key = local.user_secret_paths[k], property = "username" }
            },
            {
              secretKey = "${u.name}_password"
              remoteRef = { key = local.user_secret_paths[k], property = "password" }
            }
          ]
        ])
      )
    }
  }))
}

resource "local_file" "config_map_manifest" {
  count = var.config_map_manifest != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = var.kubernetes_namespace != null
      error_message = "You enabled 'config_map_manifest' but did not provide 'kubernetes_namespace'."
    }
  }

  filename = var.config_map_manifest

  content = format("%s%s", local.yaml_autocreate_warning, join("\n---\n", [
    for db_name in local.databases : yamlencode({
      apiVersion = "v1"
      kind       = "ConfigMap"
      metadata = {
        name      = "database-config-${db_name}"
        namespace = var.kubernetes_namespace
      }
      data = {
        "database.name" = db_name
        "database.host" = stackit_postgresflex_user.admin.host
        "database.port" = tostring(stackit_postgresflex_user.admin.port)
      }
    })
  ]))
}
