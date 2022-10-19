variable "resource_group" {
  description = "Used for tags and resource names."
  type        = string
}

variable "vpc_id" {
  description = "Specifies the VPC where the load balancer will reside."
}

variable "subnet_id" {
  description = "Specifies the subnet where the load balancer will reside."
  type        = string
}

variable "network_ids" {
  description = "Specifies the loadbalancer's backend subnet."
  type        = list(string)
}

variable "availability_zones" {
  description = "Specifies the availability zones where the LoadBalancer will be located."
  type        = list(string)
}

variable "l4_flavor_name" {
  description = "The name of the Layer-4 flavor."
  type        = string
}
