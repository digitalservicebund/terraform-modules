variable "resource_group" {
  description = "Used for tags and resource names."
  type        = string
}

variable "availability_zone" {
  description = "Specify AZs for the cluster."
  type        = string
}

variable "subnet_id" {
  description = "Subnet for the instance."
  type        = string
}

variable "vpc_id" {
  description = "VPC for the instance."
  type        = string
}

variable "flavor" {
  description = "Specifies the CPU/RAM specs of the instance."
  type        = string
}

variable "es_version" {
  description = "Specifies the elasticsearch version. "
  type        = string
  default     = "7.10.2"
}

variable "volume_type" {
  description = "Specifies the volume type. Its value can be any of the following and is case-sensitive: COMMON: indicates the SATA type. ULTRAHIGH: indicates the SSD type. Changing this parameter will create a new resource."
  default     = "ULTRAHIGH"
  type        = string
}

variable "es_access_from_security_group_ids" {
  description = "IDs of the security groups from which to allow access to the instance."
  type        = list(any)
}
