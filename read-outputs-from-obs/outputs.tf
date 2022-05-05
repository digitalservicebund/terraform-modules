output "outputs" {
  description = "The outputs stored in OBS"
  value       = jsondecode(data.opentelekomcloud_obs_bucket_object.this.body)
}
