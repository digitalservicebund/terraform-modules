variable "stack_name" {
  type = string
  description = "Label for the name of the server, used for the instance and the domains"
}

variable "instance_type" {
  type = string
  description = "instance type"
  default = "cx21"
}

variable "image" {
  type = string
  description = "the image to use for the server"
  default = "ubuntu-22.04"
}

variable "enable_ipv6" {
  type = bool
  description = "enable IPv6 for the server"
  default = false
}

variable "datacenter" {
  type = string
  description = "the datacenter to use for the server"
  default = "nbg1-dc3"
}

variable "ssh_key_ids" {
  type = list(string)
  default = []
}

variable "ssh_key_path" {
  type = string
  description = "value of the path to the SSH key"
}