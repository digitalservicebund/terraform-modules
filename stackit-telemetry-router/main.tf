locals {
  # Credentials group URN used by Terraform to manage the S3 bucket via the AWS provider.
  terraform_credentials_group_urn = (
    var.terraform_credentials_group_id != null
    ? data.stackit_objectstorage_credentials_group.existing[0].urn
    : stackit_objectstorage_credentials_group.terraform[0].urn
  )

  # Default project for router resources.
  router_project_id = var.project_id
  # Storage project fallback: use override if provided, otherwise use default project_id.
  storage_project_id = coalesce(var.log_storage_project_id, local.router_project_id)
}

# STACKIT Logs Instance
resource "stackit_logs_instance" "this" {
  project_id     = local.storage_project_id
  display_name   = "${var.name}-logs"
  description    = var.logs_description
  retention_days = var.logs_retention_days
}

resource "stackit_logs_access_token" "router" {
  project_id   = local.storage_project_id
  instance_id  = stackit_logs_instance.this.instance_id
  display_name = "${var.name}-router-ingest"
  description  = "Write-only token for the Telemetry Router to push audit logs."
  permissions  = ["write"]
}

# S3 Credentials
data "stackit_objectstorage_credentials_group" "existing" {
  count                = var.terraform_credentials_group_id != null ? 1 : 0
  project_id           = local.storage_project_id
  credentials_group_id = var.terraform_credentials_group_id
}

resource "stackit_objectstorage_credentials_group" "terraform" {
  count      = var.terraform_credentials_group_id == null ? 1 : 0
  depends_on = [stackit_objectstorage_bucket.audit_logs]
  project_id = local.storage_project_id
  name       = "${var.bucket_name}-cg"
}

resource "stackit_objectstorage_credential" "terraform" {
  count                = var.terraform_credentials_group_id == null ? 1 : 0
  project_id           = local.storage_project_id
  credentials_group_id = stackit_objectstorage_credentials_group.terraform[0].credentials_group_id
}

resource "stackit_objectstorage_credentials_group" "router" {
  depends_on = [stackit_objectstorage_bucket.audit_logs]
  project_id = local.storage_project_id
  name       = "${var.bucket_name}-router"
}

resource "stackit_objectstorage_credential" "router" {
  project_id           = local.storage_project_id
  credentials_group_id = stackit_objectstorage_credentials_group.router.credentials_group_id
}

# Telemetry Router Instance
resource "stackit_telemetryrouter_instance" "this" {
  project_id   = local.router_project_id
  display_name = "${var.name}-router"
  description  = var.telemetry_router_description
}

resource "stackit_telemetryrouter_access_token" "link_token" {
  project_id   = local.router_project_id
  instance_id  = stackit_telemetryrouter_instance.this.instance_id
  display_name = "${var.name}-link-token"
  description  = "Access token for telemetry links to authenticate against the router"
  # No TTL → token does not expire; rotate via `terraform replace` if needed.
}

# Destination 1: STACKIT Logs (OTLP)
resource "stackit_telemetryrouter_destination" "logs" {
  project_id   = local.router_project_id
  instance_id  = stackit_telemetryrouter_instance.this.instance_id
  display_name = "${var.name}-dest-logs"
  description  = "Forward audit logs to the STACKIT Logs instance via OTLP"

  config = {
    config_type = "OpenTelemetry"
    opentelemetry = {
      uri          = stackit_logs_instance.this.ingest_otlp_url
      bearer_token = stackit_logs_access_token.router.access_token
    }
  }
}

# Destination 2: S3 Bucket (WORM)
resource "stackit_telemetryrouter_destination" "s3" {
  project_id   = local.router_project_id
  instance_id  = stackit_telemetryrouter_instance.this.instance_id
  display_name = "${var.name}-dest-s3"
  description  = "Forward audit logs to the WORM S3 bucket for long-term archiving"

  config = {
    config_type = "S3"
    s3 = {
      bucket   = stackit_objectstorage_bucket.audit_logs.name
      endpoint = "https://object.storage.${var.region}.onstackit.cloud"
      access_key = {
        id     = stackit_objectstorage_credential.router.access_key
        secret = stackit_objectstorage_credential.router.secret_access_key
      }
    }
  }
}

# Organization-Wide Telemetry Link
resource "stackit_telemetrylink" "organization" {
  display_name        = var.organization_link_display_name
  description         = var.organization_link_description
  resource_type       = "organization"
  resource_id         = var.organization_id
  telemetry_router_id = stackit_telemetryrouter_instance.this.instance_id

  # Write-only token – never stored in state.
  access_token_wo         = stackit_telemetryrouter_access_token.link_token.access_token
  access_token_wo_version = 1
}
