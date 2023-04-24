// Terraform Cloudflare Record
variable "zone_id" {
  type = string
  description = "The zone ID of the domain to add the record to."
}
variable "record_type" {
  type    = string
  description = "The type of record to add."
  default = "A"
}

variable "name" {
  type = string
  description = "The name of the record."
}

variable "value" {
  type = string
  description = "The value of the record."
}

variable "ttl" {
  type = number
  description = "The TTL of the record."
  default = 300
}

variable "dependencies" {
  type = any
  description = "List of dependencies to wait for before creating the record."
  default = []
}