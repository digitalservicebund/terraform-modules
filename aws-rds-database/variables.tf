variable "database_name" {
  type        = string
  description = "Name of the RDS database to be created. Will also be used to name related resources."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the RDS database will be created."
}

variable "ingress_cidr_block" {
  type        = string
  description = "CIDR block to allow ingress traffic to the RDS database. This should be the CIDR block of the VPC or the VPC Peering."
}

variable "engine_major_version" {
  type        = string
  description = "Major version of the RDS database engine to be used. E.g., '14', '15', etc."
}

variable "instance_class" {
  type        = string
  description = "Instance class for the RDS database. E.g., 'db.t4g.micro', 'db.t3.medium', etc."
}

variable "database_subnet_group" {
  type        = string
  description = "Name of the database subnet group to be used for the RDS instance."
}

variable "username" {
  type        = string
  default     = "digitalservicebund"
  description = "Master username for the RDS database. Avoid using reserved words like 'user'."
}
variable "db_name" {
  type        = string
  default     = "digitalservicebund"
  description = "Name of the database that will be created in the RDS instance."
}
