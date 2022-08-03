variable "ingress_dns_names" {
  description = "DNS zone and hostnames to map to the loadbalancer's IP."
  type = list(object({
    zone_name = string
    hostname  = string
  }))
}

variable "loadbalancer_address" {
  description = "Public IP address to map to the subdomain."
  type        = string
}
