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

variable "node_pools" {
  description = "Map of node pools to create, with \"node_flavor\" (instance type for nodes in the node pool), \"node_count\" (expected number of nodes in the node pool, must be <= max_node_count), \"min_node_count\" (minimum number of nodes in the node pool), and \"max_node_count\" (maximum number of nodes in the node pool)."
  type = map(object({
    node_flavor    = string
    node_count     = number
    min_node_count = number
    max_node_count = number
  }))
  validation {
    condition = alltrue([
      for k, v in var.node_pools : can(regex("^[-a-z0-9]*[a-z0-9]$", k))
    ])
    error_message = "Node pool names may only contain lowercase letters, digits, and hypens, and must end with a letter or digit."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  type        = string
}

variable "autoscaler_addon_version" {
  description = "Autoscaler add-on version"
  type        = string
  validation {
    condition     = contains(["1.19.7", "1.23.6"], var.autoscaler_addon_version)
    error_message = "Unsupported addon version. To support it, add the required autoscaler_basic_blocks config to the terraform configuration and update the validation condition for this variable."
  }
}
