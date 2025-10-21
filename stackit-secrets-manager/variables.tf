variable "project_id" {
  type        = string
  description = "ID of the project that the secrets manager is created in"
}

variable "name" {
  type        = string
  description = "Name of the secrets manager instance"
}

variable "max_versions" {
  type        = number
  default     = 3
  description = "Specifies how many previous secret versions are retained."
}

variable "kubernetes_namespace" {
  description = "The Kubernetes namespace where you want to create the SecretStore manifest for External Secrets Operator."
  type        = string
  default     = "[replace with your namespace]"
}