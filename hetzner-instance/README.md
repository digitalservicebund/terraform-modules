# Hetzner Instance

This module creates an Hetzner instance.

## Access

In order to use the module, you need to create an API Access token for Hetzner

## Usage

```ruby
module "server" {
  source        = "github.com/digitalservicebund/terraform-modules//hetzner-instance?ref=88f0df1804fcb2b94556acdaecb2b4df4fe1469e"
  stack_name    = var.stack_name
  ssh_key_ids   = var.ssh_key_ids
  ssh_key_path  = var.ssh_key_path
  userdata_path = "userdata.sh"
}
```
