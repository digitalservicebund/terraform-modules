data "opentelekomcloud_dns_zone_v2" "this" {
  for_each = { for index, dns_name in var.ingress_dns_names : index => dns_name }

  name = each.value.zone_name
}

resource "opentelekomcloud_dns_recordset_v2" "A_record" {
  for_each = { for index, dns_name in var.ingress_dns_names : index => dns_name }

  zone_id = data.opentelekomcloud_dns_zone_v2.this[each.key].id
  name    = "%{if each.value.hostname != ""}${each.value.hostname}.%{endif}${each.value.zone_name}"
  ttl     = 300
  type    = "A"
  records = [
    var.loadbalancer_address,
  ]
}
