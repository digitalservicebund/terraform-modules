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
