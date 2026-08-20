output "logs_instance_id" {
  description = "The instance ID of the STACKIT Logs instance."
  value       = stackit_logs_instance.this.instance_id
}

output "logs_ingest_otlp_url" {
  description = "OTLP ingest URL of the STACKIT Logs instance. Can be used to send additional logs directly."
  value       = stackit_logs_instance.this.ingest_otlp_url
}

output "logs_datasource_url" {
  description = "Datasource URL for Grafana integration."
  value       = stackit_logs_instance.this.datasource_url
}

output "telemetry_router_instance_id" {
  description = "The instance ID of the Telemetry Router."
  value       = stackit_telemetryrouter_instance.this.instance_id
}

output "bucket_name" {
  description = "Name of the S3 audit-log bucket."
  value       = stackit_objectstorage_bucket.audit_logs.name
}

output "terraform_credentials_group_id" {
  description = "Credentials-group ID used by Terraform to manage the S3 bucket. Pass this to the AWS provider or reuse it in other modules via terraform_credentials_group_id."
  value = (
    var.terraform_credentials_group_id != null
    ? var.terraform_credentials_group_id
    : stackit_objectstorage_credentials_group.terraform[0].credentials_group_id
  )
}

output "terraform_credentials" {
  description = "S3 access credentials for the Terraform AWS provider (sensitive). Empty object when terraform_credentials_group_id was provided."
  sensitive   = true
  value = var.terraform_credentials_group_id != null ? {} : {
    access_key        = stackit_objectstorage_credential.terraform[0].access_key
    secret_access_key = stackit_objectstorage_credential.terraform[0].secret_access_key
  }
}
