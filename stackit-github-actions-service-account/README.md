# STACKIT GitHub Actions Service Account Module

This module creates a STACKIT service account for a GitHub Actions pipeline to execute Terraform. It assigns the
roles needed to manage your infrastructure and sets up [workload identity federation](https://docs.stackit.cloud)
with GitHub's OIDC provider, so the pipeline authenticates without a long-lived service account key. A dedicated
federated identity provider is created per entry in `github_subjects`, scoping access to a single branch, tag,
environment or pull request; the `aud` assertion is always enforced alongside `sub`, as required by STACKIT.

> **Note:** the resources used by this module (`stackit_authorization_project_role_assignment`,
> `stackit_service_account_federated_identity_provider`) are part of the STACKIT provider's experimental `iam`
> feature. Enable it in the **calling** configuration's provider block, or `plan`/`apply` will fail:
>
> ```hcl
> provider "stackit" {
>   default_region = "eu01"
>   experiments    = ["iam"]
> }
> ```

## Example

```hcl
module "github_actions_service_account" {
  source     = "github.com/digitalservicebund/terraform-modules//stackit-github-actions-service-account?ref=[sha of the commit you want to use]"
  project_id = "[your stackit project id]"
  name       = "gh-actions-terraform"
  roles      = ["editor"]

  github_repository = "digitalservicebund/[your repo]"
  github_subjects = [
    "ref:refs/heads/main",
    "environment:production",
  ]
}
```

## Using the service account

With our [`stackit-terraform-execution`](https://github.com/digitalservicebund/stackit-terraform-execution) action
(supports OIDC since [`93654d8`](https://github.com/digitalservicebund/stackit-terraform-execution/commit/93654d8fcae0a35c5556ac48a700ccedec975ac9)),
pass the module's `service_account_email` output as `STACKIT_SERVICE_ACCOUNT_EMAIL` instead of
`STACKIT_SERVICE_ACCOUNT_KEY`:

```yaml
permissions:
  id-token: write # required to request the OIDC token

jobs:
  terraform:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v6
      - name: Terraform Plan & Apply
        uses: digitalservicebund/stackit-terraform-execution@v1
        with:
          terraform_module: "terraform"
          STACKIT_SERVICE_ACCOUNT_EMAIL: "[output: service_account_email]"
          BACKEND_ACCESS_KEY_ID: ${{ secrets.BACKEND_ACCESS_KEY_ID }}
          BACKEND_SECRET_ACCESS_KEY: ${{ secrets.BACKEND_SECRET_ACCESS_KEY }}
```

## Restricting access further

Use `additional_assertions` to further tighten which workflows may assume the service account, e.g. by pinning the
exact workflow file:

```hcl
module "github_actions_service_account" {
  source     = "github.com/digitalservicebund/terraform-modules//stackit-github-actions-service-account?ref=[sha of the commit you want to use]"
  project_id = "[your stackit project id]"
  name       = "gh-actions-terraform"
  roles      = ["editor"]

  github_repository = "digitalservicebund/[your repo]"
  github_subjects    = ["ref:refs/heads/main"]

  additional_assertions = [
    {
      item     = "job_workflow_ref"
      operator = "equals"
      value    = "digitalservicebund/[your repo]/.github/workflows/terraform.yml@refs/heads/main"
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.10.0 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | >=0.101.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | >=0.101.0 |

## Resources

| Name | Type |
|------|------|
| [stackit_authorization_project_role_assignment.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/authorization_project_role_assignment) | resource |
| [stackit_service_account.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/service_account) | resource |
| [stackit_service_account_federated_identity_provider.github_actions](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/service_account_federated_identity_provider) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_assertions"></a> [additional\_assertions](#input\_additional\_assertions) | Additional assertions that are appended (combined with AND) to the "aud" and "sub" assertions of every federated identity provider, e.g. to further restrict access by "repository\_owner" or "workflow\_ref". | <pre>list(object({<br/>    item     = string<br/>    operator = string<br/>    value    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_audience"></a> [audience](#input\_audience) | The audience ("aud" claim) that the GitHub Actions OIDC token must present. Checking the audience is mandatory for security reasons and is always enforced by this module. | `string` | `"sts.accounts.stackit.cloud"` | no |
| <a name="input_federation_name_prefix"></a> [federation\_name\_prefix](#input\_federation\_name\_prefix) | Prefix used to build the name of the federated identity providers created for each entry in github\_subjects. | `string` | `"github-actions"` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | The GitHub repository the service account should be usable from, in the form "org/repo", e.g. "digitalservicebund/terraform-modules". | `string` | n/a | yes |
| <a name="input_github_subjects"></a> [github\_subjects](#input\_github\_subjects) | List of GitHub Actions OIDC token subject claim suffixes that are allowed to use the service account. Supported formats: "ref:refs/heads/<branch>", "ref:refs/tags/<tag>", "environment:<environment>" and "pull\_request". A separate, narrowly scoped federated identity provider is created for each entry. | `list(string)` | <pre>[<br/>  "ref:refs/heads/main"<br/>]</pre> | no |
| <a name="input_issuer"></a> [issuer](#input\_issuer) | The OIDC issuer URL of the identity provider. Defaults to GitHub's public OIDC issuer, override for GitHub Enterprise Server. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the service account | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the STACKIT project that the service account is created in | `string` | n/a | yes |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | The resource (project, folder or organization) ID the roles are assigned on. Defaults to var.project\_id. | `string` | `null` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Roles to assign to the service account, e.g. ["editor"]. Available roles can be queried using stackit-cli: `stackit curl https://authorization.api.stackit.cloud/v2/permissions`. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_actions_federations"></a> [github\_actions\_federations](#output\_github\_actions\_federations) | Map of the configured github\_subjects entries to their federation ID and the resulting full GitHub Actions OIDC subject claim |
| <a name="output_role_assignments"></a> [role\_assignments](#output\_role\_assignments) | Map of role to the ID of the role assignment resource |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email of the created service account |
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | Internal UUID of the created service account |
<!-- END_TF_DOCS -->
