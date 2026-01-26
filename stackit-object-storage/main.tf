locals {
  yaml_autocreate_warning = <<-EOT
    ###
    # DO NOT EDIT MANUALLY
    # THIS FILE IS MANAGED BY TERRAFORM
    ###
  EOT
  access_codes = {
    "read-only"  = "ro"
    "read-write" = "rw"
    "superuser"  = "su"
  }

  roles_used = toset([for name, role in var.credentials : role])
  # Either the existing terraform credentials group URN or the newly created one
  terraform_credentials_group_urn = var.terraform_credentials_group_id != null ? data.stackit_objectstorage_credentials_group.existing_terraform_credentials_group[0].urn : stackit_objectstorage_credentials_group.terraform_credentials_group[0].urn
}

resource "stackit_objectstorage_bucket" "bucket" {
  project_id = var.project_id
  name       = var.bucket_name
}

data "stackit_objectstorage_credentials_group" "existing_terraform_credentials_group" {
  count                = var.terraform_credentials_group_id != null ? 1 : 0
  project_id           = var.project_id
  credentials_group_id = var.terraform_credentials_group_id
}

# Default terraform superuser credentials
resource "stackit_objectstorage_credentials_group" "terraform_credentials_group" {
  count = var.terraform_credentials_group_id == null ? 1 : 0
  # depends_on needed to avoid 409, because of simultaneously requests
  # REF: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket
  depends_on = [stackit_objectstorage_bucket.bucket]

  project_id = var.project_id
  name       = "${var.bucket_name}-cg"
}


resource "stackit_objectstorage_credential" "terraform_credentials" {
  count                = var.terraform_credentials_group_id == null ? 1 : 0
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.terraform_credentials_group[0].credentials_group_id
}

# Credentials requested by user with specific roles
resource "stackit_objectstorage_credentials_group" "user_credentials_group" {
  # depends_on needed to avoid 409, because of simultaneously requests
  # REF: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket
  depends_on = [stackit_objectstorage_bucket.bucket]

  for_each   = local.roles_used
  project_id = var.project_id
  name       = "${var.bucket_name}-${local.access_codes[each.key]}"
}

resource "stackit_objectstorage_credential" "credential" {
  for_each             = var.credentials
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.user_credentials_group[each.value].credentials_group_id
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  count  = var.object_expiration_days != null ? 1 : 0
  bucket = stackit_objectstorage_bucket.bucket.name

  rule {
    id     = "auto-cleanup"
    status = "Enabled"

    expiration {
      days = var.object_expiration_days
    }
  }
}
