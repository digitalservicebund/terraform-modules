variable "resource_group" {
  description = "Used for tags and resource names."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-z-]{3,127}[0-9a-z]$", var.resource_group))
    error_message = "Invalid resource group name. Must be 4 to 128 lowercase letters, digits, and hyphens (-) and not ending with a hyphen."
  }
}

variable "vpc_cidr" {
  description = "Private network range for the cluster's VPC."
  type        = string
  default     = "10.1.0.0/16"
}

variable "high_availability" {
  description = "Whether the cluster should run in a redundant setup across availability zones."
  type        = bool
}

variable "min_node_count" {
  description = "Minimum number of nodes in the node pool."
  type        = number
}

variable "max_node_count" {
  description = "Maximum number of nodes in the node pool."
  type        = number
}

variable "ingress_dns_names" {
  description = "DNS zone and hostnames to map to the loadbalancer's IP."
  type = list(object({
    zone_name = string
    hostname  = string
  }))
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  type        = string
}
