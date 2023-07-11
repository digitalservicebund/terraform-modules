locals {
  user_name = var.user_name != null ? var.user_name : "access-obs-bucket-${replace(var.bucket_name, "/[^a-zA-Z0-9]+/", "_")}"
}

resource "opentelekomcloud_identity_user_v3" "this" {
  name = local.user_name
}

resource "opentelekomcloud_identity_credential_v3" "this" {
  user_id = opentelekomcloud_identity_user_v3.this.id
}

resource "opentelekomcloud_identity_group_v3" "this" {
  name = local.user_name
}

resource "opentelekomcloud_identity_user_group_membership_v3" "this" {
  user = opentelekomcloud_identity_user_v3.this.id
  groups = [
    opentelekomcloud_identity_group_v3.this.id,
  ]
}

resource "opentelekomcloud_identity_role_v3" "global" {
  description   = "Access to OBS bucket ${var.bucket_name}"
  display_name  = "${local.user_name}-global"
  display_layer = "domain"
  statement {
    effect = "Allow"
    action = concat(
      contains(var.permissions, "read") ? [
        "obs:bucket:ListBucket",
        "obs:object:GetObject"
      ] : [],
      contains(var.permissions, "write") ? [
        "obs:object:PutObjectAcl",
        "obs:object:PutObject",
        "obs:object:DeleteObject",
      ] : [],
    [])
    resource = [
      "obs:*:*:object:*",
      "obs:*:*:bucket:${var.bucket_name}"
    ]
  }
  dynamic "statement" {
    # Add this statement block only if "list_buckets" permission is requested.
    for_each = contains(var.permissions, "list_buckets") ? [{}] : []
    content {
      effect = "Allow"
      action = [
        "obs:bucket:ListAllMyBuckets"
      ]
    }
  }
}

resource "opentelekomcloud_identity_role_v3" "project" {
  count         = var.kms_key_id == null ? 0 : 1
  description   = "Access to OBS bucket ${var.bucket_name}"
  display_name  = "${local.user_name}-project"
  display_layer = "project"
  statement {
    effect = "Allow"
    action = ["kms:dek:create", "kms:dek:crypto", "kms:cmk:get"]
    resource = [
      "kms:*:*:KeyId:${var.kms_key_id}"
    ]
  }
}

data "opentelekomcloud_identity_project_v3" "MOS" {
  # According to OTC support, permissions need to be attached to the "hidden" MOS project.
  # When configuring access via the web interface, this happens automatically.
  name = "MOS"
}

resource "opentelekomcloud_identity_role_assignment_v3" "global" {
  group_id   = opentelekomcloud_identity_group_v3.this.id
  role_id    = opentelekomcloud_identity_role_v3.global.id
  project_id = data.opentelekomcloud_identity_project_v3.MOS.id
}

data "opentelekomcloud_identity_project_v3" "default_project" {
  name = "eu-de"
}
resource "opentelekomcloud_identity_role_assignment_v3" "project" {
  count      = var.kms_key_id == null ? 0 : 1
  group_id   = opentelekomcloud_identity_group_v3.this.id
  role_id    = opentelekomcloud_identity_role_v3.project[0].id
  project_id = data.opentelekomcloud_identity_project_v3.default_project.id
}
