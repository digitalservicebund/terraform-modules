output "envrc_file" {
  description = "Content of the .envrc file to set environment variables for accessing the backend bucket via 1Password."
  value       = <<-EOT
export STACKIT_SERVICE_ACCOUNT_KEY="op://Employee/STACKIT Terraform Credentials/notesPlain"

export AWS_ACCESS_KEY_ID="op://Employee/${onepassword_item.bucket_credentials.title}/ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="op://Employee/${onepassword_item.bucket_credentials.title}/SECRET_ACCESS_KEY"
  EOT
}