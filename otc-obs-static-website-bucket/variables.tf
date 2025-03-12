variable "resource_group" {
  description = "Used for tags and resource names."
  type        = string
}

variable "bucket_name" {
  type = string
}

variable "versioning_enabled" {
  description = "Toggle object versioning"
  type        = bool
  default     = false
}

variable "user_domain_names" {
  description = "Specifies the user domain names"
  type        = set(string)
  default     = []
}