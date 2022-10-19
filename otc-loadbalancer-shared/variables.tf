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
