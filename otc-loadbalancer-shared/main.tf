resource "opentelekomcloud_vpc_eip_v1" "loadbalancer" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name       = "${var.resource_group}-load-balancer"
    size       = 100
    share_type = "PER"
  }

  tags = {
    resource_group = var.resource_group
  }
}

resource "opentelekomcloud_lb_loadbalancer_v2" "this" {
  name          = var.resource_group
  vip_subnet_id = var.subnet_id

  tags = {
    resource_group = var.resource_group
  }
}

resource "opentelekomcloud_networking_floatingip_associate_v2" "loadbalancer" {
  floating_ip = opentelekomcloud_vpc_eip_v1.loadbalancer.publicip[0].ip_address
  port_id     = opentelekomcloud_lb_loadbalancer_v2.this.vip_port_id
}
