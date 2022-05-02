
output "backend_config" {
  value = <<EOT
    backend "s3" {
      bucket = "${opentelekomcloud_obs_bucket.this.bucket}"
      kms_key_id = "arn:aws:kms:eu-de:${opentelekomcloud_kms_key_v1.this.domain_id}:key/${opentelekomcloud_kms_key_v1.this.id}"
      key = "tfstate"
      region = "${opentelekomcloud_obs_bucket.this.region}"
      endpoint = "obs.${var.region}.otc.t-systems.com"
      encrypt = true
      skip_region_validation = true
      skip_credentials_validation = true
    }
  EOT
}
