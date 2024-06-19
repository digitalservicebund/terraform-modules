data "opentelekomcloud_lb_flavor_v3" "this" {
  name = var.l4_flavor_name
}

resource "opentelekomcloud_lb_loadbalancer_v3" "this" {
  name               = var.resource_group
  availability_zones = var.availability_zones

  network_ids = var.network_ids
  router_id   = var.vpc_id
  subnet_id   = var.subnet_id

  l4_flavor = data.opentelekomcloud_lb_flavor_v3.this.id
  l7_flavor = null

  public_ip {
    bandwidth_name       = var.resource_group
    ip_type              = "5_bgp"
    bandwidth_size       = 1000
    bandwidth_share_type = "PER"
  }

  tags = {
    resource_group = var.resource_group
  }
}
