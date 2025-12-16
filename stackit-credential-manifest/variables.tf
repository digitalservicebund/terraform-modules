variable "vault_name" {
  description = "Specifies the Vault name the credentials will be stored under"
  type        = string
}

variable "user" {
  description = "Specifies the user the credentials are created for"
  type        = string
}

variable "manifest_file" {
  description = "Path to the new file"
  type        = string
}

variable "manifest_name" {
  description = "Kubernetes MetaData Name property"
  type        = string
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