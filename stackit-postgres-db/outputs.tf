output "address" {
  description = "Database host address"
  value       = stackit_postgresflex_user.user.host
}

output "username" {
  description = "Database username"
  value       = stackit_postgresflex_user.user.username
}

output "password" {
  description = "Database password"
  value       = stackit_postgresflex_user.user.password
  sensitive   = true
}
