output "address" {
  description = "Database IP address"
  value       = opentelekomcloud_rds_instance_v3.this.private_ips[0]
}

output "password" {
  description = "Database password"
  value       = opentelekomcloud_rds_instance_v3.this.db[0].password
  sensitive   = true
}

output "original_password" {
  description = "Password that we hand over to the rds resource. Should be the same as 'password' output"
  value       = random_password.this.result
  sensitive   = true
}