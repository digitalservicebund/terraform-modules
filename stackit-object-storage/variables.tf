variable "project_id" {
  description = "The ID of the project where the bucket will be created."
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket."
  type        = string

  validation {
    condition     = length(var.bucket_name) <= 29
    error_message = "The bucket_name must not exceed 29 characters, because the credentials group name has a limit of 32 characters."
  }
}

variable "credentials" {
  description = "Credentials to create for the bucket. Map of credential name to role (e.g. { name = role }. Valid roles are: superuser, read-only, read-write."
  type        = map(string)
  default = {
    default = "superuser"
  }

  validation {
    condition = alltrue([
      for c in values(var.credentials) : contains(["superuser", "read-only", "read-write"], c)
    ])
    error_message = "Each credential role must be one of: superuser, read-only, read-write."

  }
}

variable "terraform_credentials_group_id" {
  description = "ID of the credentials group that is used by Terraform to manage the bucket. A credential of this credential group must be used in the AWS provider config. If not provided, a new credentials group will be created."
  type        = string
}

variable "enable_policy_creation" {
  description = "Set to false in case you want to create your own policy. WARNING: If you disable this, all credentials in the same STACKIT project have access to your bucket."
  type        = bool
  default     = true
}

variable "manage_credentials" {
  description = "Set true to add the credentials into the STACKIT Secrets Manager. The credentials will be at `object-storage/[bucket name]/[credential name]`"
  type        = bool
  default     = false
}

variable "secret_manager_instance_id" {
  description = "Instance ID of the STACKIT Secret Manager, in which the database user password will be stored if manage_credentials is true."
  type        = string
  default     = null
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace where the External Secret manifest will be applied."
  type        = string
  default     = null
}

variable "external_secret_manifest" {
  description = "Path where the external secret manifest will be stored at"
  type        = string
  default     = null
}

variable "enable_manifest_creation" {
    description = "Set to true to create an External Secret manifest for Kubernetes to access the created credentials."
    type        = bool
    default     = true
}

variable "lifecycle_days" {
  description = "Lifespan of stored data. Data will be deleted after specified value in days. Default value is 0 (no automatic deletion)"
  type        = number
  default     = 0
  validation {
    condition     = var.lifecycle_days >= 0
    error_message = "The value for lifecycle in days must be 0 (deactivated) or a positive number."
  }
}
