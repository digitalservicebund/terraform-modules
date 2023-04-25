# Cloudflare dns record

This module adds a dns to a given zone on Cloudflare.

## Access

In order to use the module, you need to create an API Access token for Cloudflare

## Usage

```ruby
module "record" {
  source     = "github.com/digitalservicebund/terraform-modules//cloudflare-record?ref=88f0df1804fcb2b94556acdaecb2b4df4fe1469e"
  zone_id    = var.cloudflare_zone_id
  name       = "${var.stack_name}.${var.domain_name}"
  value      = module.server.ipv4_address
  dependencies = [module.server]
}
```
