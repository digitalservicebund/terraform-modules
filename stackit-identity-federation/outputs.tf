output "service_account_email" {
  value       = stackit_service_account.this.email
  description = "Email of the created service account"
}

