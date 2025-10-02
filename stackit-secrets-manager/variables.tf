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