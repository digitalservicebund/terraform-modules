variable "project_id" {
  description = "The ID of the project where the bucket will be created."
  type        = string
}

variable "state_bucket_name" {
  description = "The name of the state bucket."
  type        = string

  validation {
    condition     = length(var.state_bucket_name) <= 29
    error_message = "The state_bucket_name must not exceed 29 characters, because the credentials group name has a limit of 32 characters."
  }
}

variable "write_backend_config_file" {
  type        = bool
  default     = true
  description = "Write the backend.tf file containing the configuration to connect to the state bucket."
}

variable "create_onepassword_item" {
  type        = bool
  default     = true
  description = "Create a 1Password item containing the credentials for the state bucket. Needs the 1Password CLI."
}

variable "onepassword_vault" {
  type        = string
  default     = "Employee"
  description = "The 1Password vault where the state bucket credentials item will be created in."
}

variable "write_envrc_file" {
  type        = bool
  default     = true
  description = "Write a .envrc file containing the environment variables to read the state bucket credentials from 1Password."
}
