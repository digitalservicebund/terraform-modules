variable "environment" {}
variable "repository" {}

variable "branch_name_pattern" {
  description = "The name pattern that branches must match in order to deploy to the environment."
  type        = string
  default     = "main"
}
