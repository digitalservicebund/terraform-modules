variable "resource_group" {
  description = "Used for tags and resource names."
  type        = string
  validation {
    condition     = can(regex("^[0-9a-z-]{3,127}[0-9a-z]$", var.resource_group))
    error_message = "Invalid resource group name. Must be 4 to 128 lowercase letters, digits, and hyphens (-) and not ending with a hyphen."
  }
}

variable "cluster_size" {
  description = "small (<=50 nodes) / medium (<=200 nodes) / large (<=1000 nodes)."
  type        = string
  default     = "small"
}

variable "vpc_id" {
  description = "VPC to deploy the cluster into."
  type        = string
}

variable "subnet_id" {
  description = "VPC subnet to host the cluster."
  type        = string
}

variable "high_availability" {
  description = "Whether to use a HA cluster flavor and set up a multi-AZ node pool."
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

variable "node_flavor" {
  description = "Instance type for nodes in the node pool."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  type        = string
}

variable "autoscaler_addon_version" {
  description = "Autoscaler add-on version"
  type        = string
}
