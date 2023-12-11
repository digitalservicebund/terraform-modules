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
