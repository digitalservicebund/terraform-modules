output "id" {
  description = "Loadbalancer ID"
  value       = opentelekomcloud_lb_loadbalancer_v2.this.id
}

output "public_ip_address" {
  description = "Public IP address"
  value       = opentelekomcloud_vpc_eip_v1.loadbalancer.publicip[0].ip_address
}
