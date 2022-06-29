output "address" {
  description = "Database IP address"
  value       = opentelekomcloud_rds_instance_v3.this.private_ips[0]
}

output "password" {
  description = "Database password"
  value       = random_password.this.result
  sensitive   = true
}
