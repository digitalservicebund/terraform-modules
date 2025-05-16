variable "github_repository_name" {
  type        = string
  description = "Name of the repository, including the organization identifier. E.g. digitalservicebund/terraform-modules"
}

variable "terraform_execution_policy" {
  type        = string
  description = "IAM policy to execute terraform in json format"
}