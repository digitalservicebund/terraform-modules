variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket to store Terraform state. If not provided a unique name will be generated."
  type        = string
  default     = null
}

variable "dynamo_db_table_name" {
  description = "Name of the DynamoDB Table used for state locking. Defaults to terraform-state-lock."
  type        = string
  default     = "terraform-state-lock"
}
