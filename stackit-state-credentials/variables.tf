variable "state_bucket_name" {
  type        = string
  description = "The name of the state bucket"
}

variable "access_key" {
  type        = string
  description = "The access key for the state bucket to be stored in 1Password"
}

variable "secret_access_key" {
  type        = string
  description = "The secret access key for the state bucket to be stored in 1Password"
}
