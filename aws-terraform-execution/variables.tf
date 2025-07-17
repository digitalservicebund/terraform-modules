variable "github_repository_name" {
  type        = string
  description = "Name of the repository, including the organization identifier. E.g. digitalservicebund/terraform-modules"
}

variable "terraform_execution_policy" {
  type        = string
  description = "IAM policy to execute terraform in json format"
}

variable "sso_role_arn" {
  type        = string
  default     = null
  description = "The ARN of the AWS SSO role that should be allowed to assume this role."
}

variable "role_name" {
  type        = string
  default     = "terraform-execution"
  description = "Name of the IAM role that is used to execute terraform in Github Actions."
}