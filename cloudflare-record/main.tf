resource "cloudflare_record" "record" {
  zone_id = var.cloudflare_zone_id
  name    = var.name
  value   = var.value
  type    = "${var.record_type}"
  ttl     = var.ttl
}