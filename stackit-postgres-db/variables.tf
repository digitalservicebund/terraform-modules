variable "name" {
  description = "Specifies the name of the Postgres instance."
  type        = string
}

variable "project_id" {
  description = "The ID of the STACKIT project where the bucket will be created."
  type        = string
}

variable "cpu" {
  description = "Specifies the CPU specs of the instance. Available Options: 2, 4, 8 & 16"
  type        = number
}

variable "memory" {
  description = "Specifies the memory (RAM) specs of the instance in GB. Available Options: 4, 8, 16, 32 & 128"
  type        = number
}

variable "replicas" {
  description = "Number of read replicas for the instance."
  type        = number
  default     = 1
}

variable "engine_version" {
  description = "Specifies the postgres version."
  type        = string
  default     = "17"
}

variable "disk_size" {
  description = "Size of the instance disk volume. Its value range is from 5 GB to 4000 GB."
  type        = number
  validation {
    condition     = var.disk_size >= 5 && var.disk_size <= 4000
    error_message = "The disk_size must be between 5 GB and 4000 GB, inclusive."
  }
}

variable "disk_type" {
  description = "Specifies the storage performance class. e.g. premium-perf6-stackit"
  default     = "premium-perf6-stackit"
  type        = string
}

variable "backup_schedule" {
  description = "Backup schedule in cron format. Defaults to daily at 3am UTC."
  type        = string
  default     = "0 3 * * *"
}

variable "acls" {
  description = "List of ACL IDs to associate with the database instance. This should be the cluster Egress IP Range only!"
  type        = list(string)
}

variable "manage_user_password" {
  description = "Set true to add the user password into the STACKIT Secrets Manager."
  type        = bool
  default     = true
}

variable "secret_manager_instance_id" {
  description = "Instance ID of the STACKIT Secret Manager, in which the database user password will be stored if manage_user_password is true."
  type        = string
  default     = ""
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace where the External Secret manifest will be applied."
  type        = string
  default     = "[your-namespace]"
}