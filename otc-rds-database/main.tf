resource "random_id" "this" {
  byte_length = 4
}

resource "opentelekomcloud_kms_key_v1" "this" {
  key_alias       = "${var.resource_group}-db-disk-encryption-${random_id.this.hex}"
  key_description = "Database disk encryption key"
  is_enabled      = true

  tags = {
    resource_group = var.resource_group
  }
}

resource "random_password" "this" {
  length  = 32
  special = true
  # Restrict to characters that are safe in connection URLs.
  override_special = "~!#*-_+"
}

resource "opentelekomcloud_rds_instance_v3" "this" {
  name                = var.resource_group
  availability_zone   = var.availability_zones
  ha_replication_mode = (length(var.availability_zones) > 1 ? "async" : null)

  db {
    password = random_password.this.result
    type     = "PostgreSQL"
    version  = var.engine_version
    port     = var.port
  }

  parameters = var.parameters

  security_group_id = opentelekomcloud_networking_secgroup_v2.this.id
  subnet_id         = var.subnet_id
  vpc_id            = var.vpc_id
  flavor            = var.flavor

  volume {
    disk_encryption_id = opentelekomcloud_kms_key_v1.this.id
    type               = var.volume_type
    size               = var.disk_size
  }

  backup_strategy {
    start_time = "03:00-04:00"
    keep_days  = var.backup_keep_days
    period     = "1,2,3,4,5,6,7"
  }

  tags = {
    resource_group = var.resource_group
  }

  // See https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/rds_instance_v3#notes
  lifecycle {
    ignore_changes = [
      db,
    ]
  }
}

resource "opentelekomcloud_networking_secgroup_v2" "this" {
  name = "${var.resource_group}-db"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "this" {
  for_each          = toset(var.db_access_from_security_group_ids)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port
  port_range_max    = var.port
  remote_group_id   = each.key
  security_group_id = opentelekomcloud_networking_secgroup_v2.this.id
}
