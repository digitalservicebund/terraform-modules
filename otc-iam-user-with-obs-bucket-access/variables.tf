variable "resource_group" {
  description = "Used for tags and resource names."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-z-]{3,127}[0-9a-z]$", var.resource_group))
    error_message = "Invalid resource group name. Must be 4 to 128 lowercase letters, digits, and hyphens (-) and not ending with a hyphen."
  }
}

variable "bucket_name" {
  description = "Name of the OBS bucket to grant access to."
  type        = string
}

variable "encrypted_bucket" {
  description = "Whether the OBS bucket should be encrypted."
  type        = bool
  default     = false
}

variable "permissions" {
  type        = list(string)
  description = "The scope of the access. Allowed values: read, write, list_buckets."
  validation {
    condition = alltrue([
      for t in var.permissions : contains(["read", "write", "list_buckets"], t)
    ])
    error_message = "Invalid permissions value."
  }
}

variable "user_name" {
  description = "Name of the user to access the OBS Bucket"
  type        = string
  default     = null
  validation {
    condition     = try((length(var.user_name) <= 32), true)
    error_message = "The user name can contain at most 32 characters."
  }
}

variable "kms_key_id" {
  description = "The ID of the KMS key."
  type        = string
  default     = null
}

output "validate_kms_key_present" {
  value = null
  precondition {
    condition     = !var.encrypted_bucket || var.kms_key_id != null
    error_message = "The kms_key_id is required if encrypted_bucket is true."
  }
}

output "validate_encrypted_bucket_set" {
  value = null
  precondition {
    condition     = !(var.kms_key_id != null && !var.encrypted_bucket)
    error_message = "If you want to provide kms_key_id, set encrypted_bucket to true."
  }
}
