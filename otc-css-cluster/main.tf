resource "random_id" "this" {
  byte_length = 4
}

resource "opentelekomcloud_css_cluster_v1" "this" {
  name            = var.css_clustername
  expect_node_num = var.css_number_of_nodes
  datastore {
    version = var.css_version
    type    = var.css_type
  }
  enable_https     = var.enable_https
  enable_authority = var.enable_authority
  admin_pass       = var.admin_pass
  node_config {
    flavor = var.flavor
    network_info {
      security_group_id = opentelekomcloud_networking_secgroup_v2.this.id
      network_id        = var.subnet_id
      vpc_id            = var.vpc_id
    }
    volume {
      volume_type = var.volume_type
      size        = var.volume_size
    }
    availability_zone = var.availability_zone
  }

  tags = {
    resource_group = var.resource_group
  }
}


resource "opentelekomcloud_networking_secgroup_v2" "this" {
  name = "${var.css_clustername}-css"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "this" {
  for_each          = toset(var.css_access_from_security_group_ids)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9200
  port_range_max    = 9200
  remote_group_id   = each.key
  security_group_id = opentelekomcloud_networking_secgroup_v2.this.id
}
