variable "project_id" {
  description = "The STACKIT project ID of the dedicated audit-log project where the Logs instance, Telemetry Router and S3 bucket will be created."
  type        = string
}

variable "name" {
  description = "Name prefix for all resources created by this module (e.g. 'platform-audit'). Lowercase alphanumeric + hyphens, max 20 chars."
  type        = string

  validation {
    condition     = length(var.name) <= 20 && can(regex("^[a-z0-9-]+$", var.name))
    error_message = "The name must be lowercase alphanumeric with hyphens and at most 20 characters."
  }
}

variable "region" {
  description = "STACKIT region in which all resources are created."
  type        = string
  default     = "eu01"
}

# STACKIT Logs
variable "logs_retention_days" {
  description = "Log retention period in days for the STACKIT Logs instance. Maximum is 180 days (STACKIT platform limit)."
  type        = number
  default     = 180

  validation {
    condition     = var.logs_retention_days >= 1 && var.logs_retention_days <= 180
    error_message = "logs_retention_days must be between 1 and 180."
  }
}

variable "logs_description" {
  description = "Optional description for the STACKIT Logs instance."
  type        = string
  default     = null
}

# STACKIT Telemetry Router
variable "telemetry_router_description" {
  description = "Optional description for the Telemetry Router instance."
  type        = string
  default     = null
}

# S3 / Object-Storage
variable "bucket_name" {
  description = "Name of the S3 bucket for permanent audit-log storage. Must be DNS-compliant and globally unique within the STACKIT region. Recommended prefix: 'ds-<project>-audit-logs'. Max 29 chars."
  type        = string

  validation {
    condition     = length(var.bucket_name) <= 29
    error_message = "bucket_name must not exceed 29 characters (credentials-group name limit is 32)."
  }
}

variable "terraform_credentials_group_id" {
  description = "ID of an existing credentials group used by Terraform to manage the S3 bucket (AWS provider). Set to null to let the module create a new credentials group."
  type        = string
  default     = null
}

variable "object_lock_days" {
  description = "Default WORM retention in days. Objects cannot be deleted or overwritten during this period. Minimum: 1."
  type        = number
  default     = 730 # 2 years

  validation {
    condition     = var.object_lock_days >= 1
    error_message = "object_lock_days must be at least 1."
  }
}

variable "object_lock_mode" {
  description = "Object-Lock retention mode: COMPLIANCE (immutable, even for admins) or GOVERNANCE (admin override possible)."
  type        = string
  default     = "COMPLIANCE"

  validation {
    condition     = contains(["COMPLIANCE", "GOVERNANCE"], var.object_lock_mode)
    error_message = "object_lock_mode must be COMPLIANCE or GOVERNANCE."
  }
}

variable "lifecycle_expiration_days" {
  description = "After how many days objects are automatically deleted. Should be >= object_lock_days so WORM protection expires first. Set to null to disable automatic deletion."
  type        = number
  default     = 740 # 2 years + 10 days; expires slightly after object_lock_days

  validation {
    condition     = var.lifecycle_expiration_days == null || var.lifecycle_expiration_days >= 1
    error_message = "lifecycle_expiration_days must be a positive number or null."
  }
}

# Organization-Wide Telemetry Link
variable "organization_id" {
  description = "The STACKIT organization ID (UUID) that should be captured by the platform-managed telemetry link. This creates one organization-wide link."
  type        = string
}

variable "organization_link_display_name" {
  description = "Display name for the platform-managed organization telemetry link."
  type        = string
  default     = "Platform Audit Logs"
}

variable "organization_link_description" {
  description = "Optional description for the platform-managed organization telemetry link."
  type        = string
  default     = null
}
