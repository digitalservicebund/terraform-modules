variable "resource_group" {
  description = "Used for tags and resource names."
  type        = string
}

variable "availability_zones" {
  description = "Specify two AZs for a primary/standby setup."
  type        = list(string)
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

variable "version" {
  description = "Specifies the database version. PostgreSQL supports 12, 11, 10. The default value is 12."
  type        = string
  default     = "12"
}

variable "port" {
  description = "Specifies the database port. The PostgreSQL database port ranges from 2100 to 9500, the default value is 5432."
  type        = string
  default     = "5432"
}

variable "disk_size" {
  description = "Size of the instance disk volume. Its value range is from 40 GB to 4000 GB. The value must be a multiple of 10."
  type        = string
}

variable "volume_type" {
  description = "Specifies the volume type. Its value can be any of the following and is case-sensitive: COMMON: indicates the SATA type. ULTRAHIGH: indicates the SSD type. Changing this parameter will create a new resource."
  default     = "COMMON"
  type        = string
}

variable "backup_keep_days" {
  description = "Specifies the retention days for specific backup files. The value range is from 0 to 732. If this parameter is not specified or set to 0, the automated backup policy is disabled."
  type        = string
}

variable "db_access_from_security_group_ids" {
  description = "IDs of the security groups from which to allow access to the instance."
  type        = list(any)
}
