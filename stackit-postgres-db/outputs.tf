output "address" {
  description = "Database host address"
  value       = stackit_postgresflex_user.user.host
}

output "password" {
  description = "Database password"
  value       = stackit_postgresflex_user.user.password
  sensitive   = true
}
