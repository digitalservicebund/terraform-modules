variable "resource_group" {
  description = "Used for tags and resource names."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-z-]{3,127}[0-9a-z]$", var.resource_group))
    error_message = "Invalid resource group name. Must be 4 to 128 lowercase letters, digits, and hyphens (-) and not ending with a hyphen."
  }
}

variable "vpc_cidr" {
  description = "Private network range for the VPC."
  type        = string
}

variable "high_availability" {
  description = "Influences AZ selection and loadbalancer flavor."
  type        = bool
}
