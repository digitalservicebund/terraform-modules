data "opentelekomcloud_vpc_subnet_v1" "subnet" {
  id = local.subnet_id
}

locals {
  openstack_subnet_id = data.opentelekomcloud_vpc_subnet_v1.subnet.subnet_id
  vpc_id    = var.vpc_id == null ? opentelekomcloud_vpc_v1.this[0].id : var.vpc_id
  subnet_id = var.openstack_subnet_id == null ? opentelekomcloud_vpc_subnet_v1.this[0].id : var.openstack_subnet_id
}

resource "opentelekomcloud_vpc_v1" "this" {
  count = var.vpc_id == null ? 1 : 0
  name  = var.resource_group
  cidr  = var.vpc_cidr

  tags = {
    resource_group = var.resource_group
  }
}

resource "opentelekomcloud_vpc_subnet_v1" "this" {
  count  = var.openstack_subnet_id == null ? 1 : 0
  name   = var.resource_group
  cidr   = cidrsubnet(var.vpc_cidr, 4, 1)
  vpc_id = var.vpc_id == null ? opentelekomcloud_vpc_v1.this[0].id : var.vpc_id

  gateway_ip = cidrhost(cidrsubnet(var.vpc_cidr, 4, 1), 1)
}

# nodes in the private network need a NAT gateway to make outbound connections to the internet
resource "opentelekomcloud_nat_gateway_v2" "this" {
  count               = var.vpc_id == null ? 1 : 0
  name                = var.resource_group
  spec                = "1" # "small"
  router_id           = local.vpc_id
  internal_network_id = local.subnet_id
}

resource "opentelekomcloud_networking_floatingip_v2" "nat" {}

resource "opentelekomcloud_nat_snat_rule_v2" "this" {
  count          = var.vpc_id == null ? 1 : 0
  nat_gateway_id = opentelekomcloud_nat_gateway_v2.this[0].id
  floating_ip_id = opentelekomcloud_networking_floatingip_v2.nat.id
  source_type    = 0
  network_id     = local.subnet_id
}
