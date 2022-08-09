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

resource "null_resource" "backend_config" {
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF > backend.tf
terraform {
  backend "s3" {
    bucket                      = "${opentelekomcloud_obs_bucket.this.bucket}"
    kms_key_id                  = "arn:aws:kms:eu-de:${opentelekomcloud_kms_key_v1.this.domain_id}:key/${opentelekomcloud_kms_key_v1.this.id}"
    key                         = "tfstate"
    region                      = "${opentelekomcloud_obs_bucket.this.region}"
    endpoint                    = "obs.${var.region}.otc.t-systems.com"
    encrypt                     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
EOF
    EOT
  }
}
