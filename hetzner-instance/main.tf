resource "hcloud_firewall" "firewall" {
  name = "${var.stack_name}-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80" //http
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443" //https
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22" //ssh
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

}

resource "hcloud_server" "server" {
  name        = var.stack_name
  image       = var.image
  server_type = var.instance_type
  datacenter  = var.datacenter
  ssh_keys    = var.ssh_key_ids
  user_data   = file("${var.userdata_path}")
  firewall_ids = [ hcloud_firewall.firewall.id ]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = var.enable_ipv6
  }
}