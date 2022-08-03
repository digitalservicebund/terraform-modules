resource "opentelekomcloud_vpc_v1" "this" {
  name = var.resource_group
  cidr = var.vpc_cidr

  tags = {
    resource_group = var.resource_group
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "this" {
  name   = var.resource_group
  cidr   = cidrsubnet(var.vpc_cidr, 4, 1)
  vpc_id = opentelekomcloud_vpc_v1.this.id

  gateway_ip = cidrhost(cidrsubnet(var.vpc_cidr, 4, 1), 1)
}

# nodes in the private network need a NAT gateway to make outbound connections to the internet
resource "opentelekomcloud_nat_gateway_v2" "this" {
  name                = var.resource_group
  spec                = "1" # "small"
  router_id           = opentelekomcloud_vpc_v1.this.id
  internal_network_id = opentelekomcloud_vpc_subnet_v1.this.id
}

resource "opentelekomcloud_networking_floatingip_v2" "nat" {}

resource "opentelekomcloud_nat_snat_rule_v2" "this" {
  nat_gateway_id = opentelekomcloud_nat_gateway_v2.this.id
  floating_ip_id = opentelekomcloud_networking_floatingip_v2.nat.id
  source_type    = 0
  network_id     = opentelekomcloud_vpc_subnet_v1.this.id
}

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
  vip_subnet_id = opentelekomcloud_vpc_subnet_v1.this.subnet_id

  tags = {
    resource_group = var.resource_group
  }
}

resource "opentelekomcloud_networking_floatingip_associate_v2" "loadbalancer" {
  floating_ip = opentelekomcloud_vpc_eip_v1.loadbalancer.publicip[0].ip_address
  port_id     = opentelekomcloud_lb_loadbalancer_v2.this.vip_port_id
}
