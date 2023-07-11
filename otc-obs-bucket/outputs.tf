output "id" {
  description = "The name of the bucket."
  value       = opentelekomcloud_obs_bucket.this.id
}

output "domain_name" {
  description = "The bucket domain name."
  value       = opentelekomcloud_obs_bucket.this.bucket_domain_name
}

output "region" {
  description = "The region this bucket resides in."
  value       = opentelekomcloud_obs_bucket.this.region
}

output "kms_key_id" {
  description = "The ID of the KMS key."
  value       = opentelekomcloud_kms_key_v1.this.id
}
