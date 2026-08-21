output "logs_instance_id" {
  description = "The instance ID of the STACKIT Logs instance (created in log_storage_project_id or project_id if not separated)."
  value       = stackit_logs_instance.this.instance_id
}

output "telemetry_router_instance_id" {
  description = "The instance ID of the Telemetry Router (created in project_id)."
  value       = stackit_telemetryrouter_instance.this.instance_id
}
