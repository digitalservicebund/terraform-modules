resource "hcloud_server" "server" {
  name        = "${var.stack_name}"
  image       = "${var.image}"
  server_type = "${var.instance_type}}"
  datacenter  = "${var.datacenter}"
  ssh_keys    = var.ssh_key_ids
  user_data   = file("userdata.sh")
  public_net {
    ipv4_enabled = true
    ipv6_enabled = var.enable_ipv6
  }
}