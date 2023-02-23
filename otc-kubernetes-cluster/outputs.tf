output "node_security_group_id" {
  description = "Security group in which nodes get placed."
  value       = module.cluster.node_security_group_id
}

output "vpc_id" {
  description = "The ID of the cluster's VPC."
  value       = module.network.vpc_id
}

output "subnet_id" {
  description = "The ID of the cluster's subnet."
  value       = module.network.subnet_id
}

output "openstack_subnet_id" {
  description = "The OpenStack subnet ID of the created subnet, required in some places, e.g. when configuring VPNaaS."
  value       = module.network.openstack_subnet_id
}
