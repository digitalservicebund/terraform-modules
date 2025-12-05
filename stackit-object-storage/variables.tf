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

variable "credentials_names" {
  description = "Names of credentials to create for the bucket. Defaults to ['default']."
  type        = list(string)
  default     = ["default"]
}

variable "manage_credentials" {
  description = "Set true to add the credentials into the STACKIT Secrets Manager."
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
  default     = "[your-namespace]"
}