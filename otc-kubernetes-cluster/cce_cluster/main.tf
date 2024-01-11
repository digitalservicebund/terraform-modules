locals {
  region = "eu-de"
}

data "opentelekomcloud_identity_project_v3" "eu_de" {
  name = local.region
}

data "opentelekomcloud_cce_addon_template_v3" "autoscaler" {
  addon_version = var.autoscaler_addon_version
  addon_name    = "autoscaler"
}

data "opentelekomcloud_cce_addon_template_v3" "npd" {
  addon_version = var.npd_addon_version
  addon_name    = "npd"
}

resource "opentelekomcloud_vpc_eip_v1" "this" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name       = "${var.resource_group}-cluster"
    size       = 100
    share_type = "PER"
  }

  tags = {
    resource_group = var.resource_group
  }

  lifecycle {
    ignore_changes = [
      publicip,
    ]
  }
}

resource "opentelekomcloud_cce_cluster_v3" "this" {
  name = var.resource_group

  cluster_version        = var.kubernetes_version
  cluster_type           = "VirtualMachine"
  flavor_id              = "cce.%{if var.high_availability}s2%{else}s1%{endif}.${var.cluster_size}"
  container_network_type = "overlay_l2"
  multi_az               = var.high_availability

  # Prevent cluster certificates to be stored in the state file!
  ignore_certificate_users_data    = true
  ignore_certificate_clusters_data = true

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  # Assign public IP for kubectl access to the API.
  eip = opentelekomcloud_vpc_eip_v1.this.publicip[0].ip_address

  timeouts {
    create = "60m"
    delete = "60m"
  }
}

resource "random_id" "keypair_id" {
  for_each    = var.node_pools
  byte_length = 4
}

resource "opentelekomcloud_compute_keypair_v2" "this" {
  for_each   = var.node_pools
  name       = "${var.resource_group}-nodes-${each.key}-${random_id.keypair_id[each.key].hex}"
  public_key = each.value.ssh_public_key
}

resource "opentelekomcloud_cce_node_pool_v3" "this" {
  for_each = var.node_pools

  name = "${var.resource_group}-${each.key}"

  cluster_id         = opentelekomcloud_cce_cluster_v3.this.id
  flavor             = each.value.node_flavor
  os                 = "CentOS 7.7"
  availability_zone  = var.high_availability ? "random" : "eu-de-01"
  key_pair           = opentelekomcloud_compute_keypair_v2.this[each.key].name
  initial_node_count = each.value.node_count

  scale_enable             = true
  min_node_count           = each.value.min_node_count
  max_node_count           = each.value.max_node_count
  scale_down_cooldown_time = 100
  priority                 = 1

  root_volume {
    size       = 40
    volumetype = "SATA"
  }

  data_volumes {
    size       = 100
    volumetype = "SATA"
  }

  dynamic "taints" {
    for_each = lookup(each.value, "taints", [])
    content {
      key    = taints.value.key
      value  = taints.value.value
      effect = taints.value.effect
    }
  }

  user_tags = {
    resource_group = var.resource_group
  }

  lifecycle {
    ignore_changes = [
      k8s_tags,
    ]
  }
}

resource "opentelekomcloud_cce_addon_v3" "autoscaler" {
  template_name    = data.opentelekomcloud_cce_addon_template_v3.autoscaler.addon_name
  template_version = data.opentelekomcloud_cce_addon_template_v3.autoscaler.addon_version
  cluster_id       = opentelekomcloud_cce_cluster_v3.this.id

  values {
    basic = {
      "cceEndpoint" = "https://cce.${opentelekomcloud_cce_cluster_v3.this.region}.otc.t-systems.com"
      "ecsEndpoint" = "https://ecs.${opentelekomcloud_cce_cluster_v3.this.region}.otc.t-systems.com"
      "region"      = opentelekomcloud_cce_cluster_v3.this.region
      "swr_addr"    = data.opentelekomcloud_cce_addon_template_v3.autoscaler.swr_addr
      "swr_user"    = data.opentelekomcloud_cce_addon_template_v3.autoscaler.swr_user
    }

    custom = {
      "cluster_id" : opentelekomcloud_cce_cluster_v3.this.id,
      "tenant_id" : data.opentelekomcloud_identity_project_v3.eu_de.id,
      "coresTotal" : 32000,
      "expander" : "priority",
      "logLevel" : 4,
      "maxEmptyBulkDeleteFlag" : 10,
      "maxNodeProvisionTime" : 15,
      "maxNodesTotal" : 1000,
      "memoryTotal" : 128000,
      "scaleDownDelayAfterAdd" : 10,
      "scaleDownDelayAfterDelete" : 10,
      "scaleDownDelayAfterFailure" : 3,
      "scaleDownEnabled" : true,
      "scaleDownUnneededTime" : 10,
      "scaleDownUtilizationThreshold" : 0.5,
      "scaleUpCpuUtilizationThreshold" : 1,
      "scaleUpMemUtilizationThreshold" : 1,
      "scaleUpUnscheduledPodEnabled" : true,
      "scaleUpUtilizationEnabled" : true,
      "unremovableNodeRecheckTimeout" : 5
    }
  }
}

resource "opentelekomcloud_cce_addon_v3" "npd" {
  template_name    = data.opentelekomcloud_cce_addon_template_v3.npd.addon_name
  template_version = data.opentelekomcloud_cce_addon_template_v3.npd.addon_version
  cluster_id       = opentelekomcloud_cce_cluster_v3.this.id

  values {
    basic = {
      "image_version" : data.opentelekomcloud_cce_addon_template_v3.npd.addon_version,
      "swr_addr" : data.opentelekomcloud_cce_addon_template_v3.npd.swr_addr,
      "swr_user" : data.opentelekomcloud_cce_addon_template_v3.npd.swr_user
    }

    custom = {}
  }
}
