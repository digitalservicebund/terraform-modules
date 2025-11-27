module "object_storage" {
  source      = "../stackit-object-storage"
  project_id  = var.project_id
  bucket_name = var.state_bucket_name
}


locals {
  backend_file = <<-EOT
terraform {
  backend "s3" {
    bucket       = "${module.object_storage.bucket_name}"
    key          = "tfstate-backend"
    use_lockfile = true
    endpoints = {
      s3 = "https://object.storage.eu01.onstackit.cloud"
    }
    region                      = "eu01"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    skip_requesting_account_id  = true
  }
}
  EOT
  envrc_file = <<-EOT
export STACKIT_SERVICE_ACCOUNT_KEY="op://Employee/STACKIT Terraform Credentials/notesPlain"

export AWS_ACCESS_KEY_ID="op://Employee/${module.object_storage.bucket_name} credentials/ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="op://Employee/${module.object_storage.bucket_name} credentials/SECRET_ACCESS_KEY"
  EOT

  onepassword_command = "op item create --category 'Secure Note' --title '${module.object_storage.bucket_name} credentials' 'ACCESS_KEY_ID[text]=${module.object_storage.credentials["default"].access_key}' 'SECRET_ACCESS_KEY[text]=${module.object_storage.credentials["default"].secret_access_key}'"
}

resource "null_resource" "backend_config" {
  count = var.write_backend_config_file ? 1 : 0

  triggers = {
    bucket_name = module.object_storage.bucket_name
  }

  provisioner "local-exec" {
    command = <<-EOT
echo '${local.backend_file}' > backend.tf
    EOT
  }
}

resource "null_resource" "onepassword" {
  count = var.create_onepassword_item ? 1 : 0

  provisioner "local-exec" {
    command = local.onepassword_command
  }
}


resource "null_resource" "envrc_file" {
  count = var.write_envrc_file ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
echo '${local.envrc_file}' > .envrc
    EOT
  }
}