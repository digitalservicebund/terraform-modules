locals {
  bucket_name = replace(lower("${var.resource_group}-terraform-backend-bucket"), "_", "-")
}

resource "opentelekomcloud_obs_bucket" "this" {
  bucket        = local.bucket_name
  acl           = "private"
  versioning    = true
  force_destroy = true

  server_side_encryption {
    algorithm  = "kms"
    kms_key_id = opentelekomcloud_kms_key_v1.this.id
  }

  tags = {
    resource_group = var.resource_group
  }
}

resource "random_id" "this" {
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "this" {
  key_alias       = "${local.bucket_name}-key-${random_id.this.hex}"
  key_description = "${local.bucket_name} encryption key"
  pending_days    = 7
  is_enabled      = "true"

  tags = {
    resource_group = var.resource_group
  }
}
