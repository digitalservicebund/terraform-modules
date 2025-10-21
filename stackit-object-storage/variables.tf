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
