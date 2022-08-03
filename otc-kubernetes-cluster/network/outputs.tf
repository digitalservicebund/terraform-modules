output "vpc_id" {
  description = "The ID of the created VPC."
  value       = opentelekomcloud_vpc_v1.this.id
}

output "subnet_id" {
  description = "The ID of the created subnet."
  value       = opentelekomcloud_vpc_subnet_v1.this.id
}

output "openstack_subnet_id" {
  description = "The OpenStack subnet ID of the created subnet, required in some places, e.g. when configuring VPNaaS."
  value       = opentelekomcloud_vpc_subnet_v1.this.subnet_id
}

output "loadbalancer_id" {
  description = "The ID of the created load balancer."
  value       = opentelekomcloud_lb_loadbalancer_v3.this.id
}

output "loadbalancer_address" {
  description = "The public IP adress of the created loadbalancer."
  value       = opentelekomcloud_lb_loadbalancer_v3.this.public_ip[0].address
}
