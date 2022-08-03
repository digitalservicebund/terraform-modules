data "opentelekomcloud_identity_project_v3" "eu_de" {
  name = "eu-de"
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

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  # Assign public IP for kubectl access to the API.
  eip = opentelekomcloud_vpc_eip_v1.this.publicip[0].ip_address

  timeouts {
    create = "60m"
    delete = "60m"
  }

  lifecycle {
    ignore_changes = [
      installed_addons,
    ]
  }
}

resource "opentelekomcloud_cce_node_pool_v3" "this" {
  name = var.resource_group

  cluster_id         = opentelekomcloud_cce_cluster_v3.this.id
  flavor             = var.node_flavor
  os                 = "CentOS 7.7"
  availability_zone  = var.high_availability ? "random" : "eu-de-01"
  key_pair           = opentelekomcloud_compute_keypair_v2.this.name
  initial_node_count = var.min_node_count

  scale_enable             = true
  min_node_count           = var.min_node_count
  max_node_count           = var.max_node_count
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

  user_tags = {
    resource_group = var.resource_group
  }

  lifecycle {
    ignore_changes = [
      k8s_tags,
      status,
    ]
  }
}

resource "opentelekomcloud_compute_keypair_v2" "this" {
  name = "${var.resource_group}-nodes"

  lifecycle {
    ignore_changes = [
      private_key,
      public_key,
    ]
  }
}

resource "opentelekomcloud_cce_addon_v3" "autoscaler" {
  template_name    = "autoscaler"
  template_version = "1.19.7"
  cluster_id       = opentelekomcloud_cce_cluster_v3.this.id

  values {
    basic = {
      "cceEndpoint" : "https://cce.eu-de.otc.t-systems.com",
      "ecsEndpoint" : "https://ecs.eu-de.otc.t-systems.com",
      "image_version" : "1.19.7",
      "platform" : "linux-amd64",
      "region" : "eu-de",
      "swr_addr" : "100.125.7.25:20202",
      "swr_user" : "hwofficial"
    }

    custom = {
      "cluster_id" : opentelekomcloud_cce_cluster_v3.this.id,
      "tenant_id" : data.opentelekomcloud_identity_project_v3.eu_de.id,
      "coresTotal" : 32000,
      "expander" : "priority",
      "logLevel" : 4,
      "maxEmptyBulkDeleteFlag" : 10,
      "maxNodeProvisionTime" : 15,
      "maxNodesTotal" : var.max_node_count,
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

data "opentelekomcloud_cce_cluster_kubeconfig_v3" "this" {
  cluster_id = opentelekomcloud_cce_cluster_v3.this.id
}
