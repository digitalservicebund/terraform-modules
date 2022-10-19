output "id" {
  description = "Loadbalancer ID"
  value       = opentelekomcloud_lb_loadbalancer_v3.this.id
}

output "public_ip_address" {
  description = "Public IP address"
  value       = opentelekomcloud_lb_loadbalancer_v3.this.public_ip[0].address
}
