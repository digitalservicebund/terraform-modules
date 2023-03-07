output "vpc_id" {
  description = "The ID of the created VPC."
  value       = local.vpc_id
}

output "subnet_id" {
  description = "The ID of the created subnet."
  value       = local.subnet_id
}

output "openstack_subnet_id" {
  description = "The OpenStack subnet ID of the created subnet, required in some places, e.g. when configuring VPNaaS."
  value       = local.openstack_subnet_id
}
