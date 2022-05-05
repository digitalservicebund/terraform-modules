variable "resource_group" {
  description = "Used for tags and resource names."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-z-]{3,127}[0-9a-z]$", var.resource_group))
    error_message = "Invalid resource group name. Must be 4 to 128 lowercase letters, digits, and hyphens (-) and not ending with a hyphen."
  }
}

variable "region" {
  type        = string
  description = "OTC region for the project: eu-de (default) or eu-nl"
  default     = "eu-de"
  validation {
    condition     = contains(["eu-de", "eu-nl"], var.region)
    error_message = "Allowed values for region are \"eu-de\" and \"eu-nl\"."
  }
}

variable "outputs" {
  type        = map(any)
  description = "The outputs to store in OBS"
}
