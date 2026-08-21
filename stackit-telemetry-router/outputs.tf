output "logs_instance_id" {
  description = "The instance ID of the STACKIT Logs instance (created in log_storage_project_id or project_id if not separated)."
  value       = stackit_logs_instance.this.instance_id
}

output "telemetry_router_instance_id" {
  description = "The instance ID of the Telemetry Router (created in project_id)."
  value       = stackit_telemetryrouter_instance.this.instance_id
}

output "bucket_name" {
  description = "Name of the S3 audit-log bucket (created in log_storage_project_id or project_id if not separated)."
  value       = stackit_objectstorage_bucket.audit_logs.name
}

output "terraform_credentials_group_id" {
  description = "Credentials group ID for Terraform to manage the S3 bucket. Use with AWS provider."
  value = (
    var.terraform_credentials_group_id != null
    ? var.terraform_credentials_group_id
    : stackit_objectstorage_credentials_group.terraform[0].credentials_group_id
  )
}
