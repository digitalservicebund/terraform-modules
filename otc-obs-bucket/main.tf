resource "random_id" "this" {
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "this" {
  key_alias       = "${var.bucket_name}-key-${random_id.this.hex}"
  key_description = "Encryption at rest key"
  pending_days    = 7
  is_enabled      = true

  tags = {
    resource_group = var.resource_group
  }
}

resource "opentelekomcloud_obs_bucket" "this" {
  bucket     = var.bucket_name
  acl        = "private"
  versioning = true

  server_side_encryption {
    algorithm  = "kms"
    kms_key_id = opentelekomcloud_kms_key_v1.this.id
  }

  tags = {
    resource_group = var.resource_group
  }
}
