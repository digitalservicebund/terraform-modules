locals {
  bucket_name = replace(lower("${var.resource_group}-terraform-outputs-bucket"), "_", "-")
}

data "opentelekomcloud_obs_bucket_object" "this" {
  bucket = local.bucket_name
  key    = "outputs.json"
}
