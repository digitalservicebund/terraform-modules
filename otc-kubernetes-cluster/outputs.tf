output "kubeconfig" {
  description = "kubeconfig yaml for connecting to the cluster."
  value       = module.cluster.kubeconfig
}

output "loadbalancer_id" {
  description = "The ID of the created load balancer."
  value       = module.network.loadbalancer_id
}

output "loadbalancer_ip_address" {
  description = "The IP address of the created load balancer."
  value       = module.network.loadbalancer_address
}

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
