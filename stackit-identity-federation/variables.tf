variable "project_id" {
  type        = string
  description = "ID of the STACKIT project that the service account is created in"
}

variable "name" {
  type        = string
  description = "Name of the service account"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,60}$", var.name))
    error_message = "The name must not be empty. Use up to 60 lowercase letters, numbers, or hyphens."
  }
}

variable "roles" {
  type        = list(string)
  description = "Roles to assign to the service account, e.g. [\"editor\"]. Available roles can be queried using stackit-cli: `stackit curl https://authorization.api.stackit.cloud/v2/permissions`."

  validation {
    condition     = length(var.roles) > 0
    error_message = "At least one role must be provided."
  }
}

variable "resource_id" {
  type        = string
  default     = null
  description = "The resource (project, folder or organization) ID the roles are assigned on. Defaults to var.project_id."
}

variable "github_repository" {
  type        = string
  description = "The GitHub repository the service account should be usable from, in the form \"org/repo\", e.g. \"digitalservicebund/terraform-modules\"."

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "The github_repository must be in the form \"org/repo\"."
  }
}

variable "github_subjects" {
  type        = list(string)
  default     = ["ref:refs/heads/main"]
  description = "List of GitHub Actions OIDC token subject claim suffixes that are allowed to use the service account. Supported formats: \"ref:refs/heads/<branch>\", \"ref:refs/tags/<tag>\", \"environment:<environment>\" and \"pull_request\". A separate, narrowly scoped federated identity provider is created for each entry."

  validation {
    condition = length(var.github_subjects) > 0 && alltrue([
      for subject in var.github_subjects :
      can(regex("^(ref:refs/(heads|tags)/.+|environment:.+|pull_request)$", subject))
    ])
    error_message = "Each github_subjects entry must be one of \"ref:refs/heads/<branch>\", \"ref:refs/tags/<tag>\", \"environment:<environment>\" or \"pull_request\"."
  }
}

variable "audience" {
  type        = string
  default     = "sts.accounts.stackit.cloud"
  description = "The audience (\"aud\" claim) that the GitHub Actions OIDC token must present. Checking the audience is mandatory for security reasons and is always enforced by this module."
}

variable "issuer" {
  type        = string
  default     = "https://token.actions.githubusercontent.com"
  description = "The OIDC issuer URL of the identity provider. Defaults to GitHub's public OIDC issuer, override for GitHub Enterprise Server."
}

variable "federation_name_prefix" {
  type        = string
  default     = "github-actions"
  description = "Prefix used to build the name of the federated identity providers created for each entry in github_subjects."
}

variable "additional_assertions" {
  type = list(object({
    item     = string
    operator = string
    value    = string
  }))
  default     = []
  description = "Additional assertions that are appended (combined with AND) to the \"aud\" and \"sub\" assertions of every federated identity provider, e.g. to further restrict access by \"repository_owner\" or \"workflow_ref\"."
}
