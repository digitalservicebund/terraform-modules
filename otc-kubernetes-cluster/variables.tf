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

variable "node_pools" {
  description = <<EOF
  Map of node pools to create, with:
  - "node_flavor" (instance type for nodes in the node pool),
  - "node_count" (expected number of nodes in the node pool, must be <= max_node_count),
  - "min_node_count" (minimum number of nodes in the node pool),
  - "max_node_count" (maximum number of nodes in the node pool),
  - "ssh_public_key" (SSH public key to inject into nodes).
  EOF
}

variable "ingress_loadbalancer_address" {
  description = "IP address of the ingress load balancer."
  type        = string
}

variable "ingress_dns_names" {
  description = "DNS zone and hostnames to map to the loadbalancer's IP."
  type = list(object({
    zone_name = string
    hostname  = string
  }))
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "autoscaler_addon_version" {
  description = "Autoscaler add-on version"
  type        = string
}

variable "vpc_id" {
  description = "Id of the vpc that should be used"
  default     = null
  type        = string
}

variable "openstack_subnet_id" {
  description = "The OpenStack subnet ID of the subnet that should be used"
  default     = null
  type        = string
}
