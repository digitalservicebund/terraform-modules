# STACKIT Identity Federation Module

This module creates a STACKIT service account and sets up [workload identity federation](https://docs.stackit.cloud/platform/access-and-identity/service-accounts/how-tos/manage-service-account-federations/)
for it, so pipelines can authenticate without a long-lived service account key. It grants the access needed to
manage your infrastructure: pass a list of `permissions` and the module creates a dedicated custom role containing
exactly those permissions (least privilege). Existing roles can be assigned via `roles`, instead of or in addition to
`permissions`. It currently targets GitHub Actions as the OIDC identity provider: a dedicated federated
identity provider is created per entry in `github_subjects`, scoping access to a single branch, tag, environment or
pull request; the `aud` assertion is always enforced alongside `sub`, as required by STACKIT.

> **Note:** the resources used by this module (`stackit_authorization_{project,folder,organization}_role_assignment`,
> `stackit_authorization_{project,folder,organization}_custom_role`, `stackit_service_account_federated_identity_provider`)
> are part of the STACKIT provider's experimental `iam` feature. Enable it in the **calling** configuration's provider
> block, or `plan`/`apply` will fail:
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
  source     = "github.com/digitalservicebund/terraform-modules//stackit-identity-federation?ref=[sha of the commit you want to use]"
  project_id = "[your stackit project id]"
  name       = "gh-actions-terraform"

  # preferred: a dedicated custom role is created with exactly these permissions
  permissions = [
    "iam.subject.get",
    "resourcemanager.project.get",
  ]

  # optional: assign existing (predefined or custom) roles as well
  # roles = ["editor"]

  github_repository = "digitalservicebund/[your repo]"
  github_subjects = [
    "ref:refs/heads/main",
    "environment:production",
  ]
}
```

## Permissions and roles

Prefer `permissions` over `roles`: the module then creates a custom role named `service-account.<name>` and assigns it to
the service account, so the pipeline only gets what it actually needs. Available permissions can be queried using stackit-cli:
`stackit curl https://authorization.api.stackit.cloud/v2/permissions`.

`roles` remains available for predefined roles (e.g. `editor`) or custom roles managed elsewhere. If both are set, the
service account is assigned the listed roles **and** the generated custom role. At least one of the two must be
non-empty.

The custom role and the role assignments are created on the project given by `project_id`, which is the intended use.
Granting access on a folder or organization instead is possible but rarely needed, see the `folder_id` and
`organization_id` variables below.

## GitHub repository format and immutable subject claims

`github_repository` normally takes the plain `"org/repo"` form, e.g. `"digitalservicebund/terraform-modules"`.

GitHub is rolling out an **immutable default subject format** for the OIDC `sub` claim: repositories created after
July 15, 2026 (or opted in to immutable subject claims) include the owner and repository IDs, e.g.
`repo:octo-org@123456/octo-repo@456789:ref:refs/heads/main` instead of `repo:octo-org/octo-repo:ref:refs/heads/main`.
See [GitHub's OIDC reference](https://docs.github.com/en/actions/reference/security/oidc#immutable-subject-claims)
for details.

To support this, `github_repository` also accepts the `"org@org-id/repo@repo-id"` form (and an optional leading
`"repo:"` prefix, which is not duplicated), e.g.:

```hcl
github_repository = "digitalservicebund@123456/[your repo]@456789"
```

You can check whether a repository uses immutable subject claims, and find the exact `sub` format it issues,
under **Settings → Actions → General → OIDC** in the GitHub UI (organization or repository level).

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
  source     = "github.com/digitalservicebund/terraform-modules//stackit-identity-federation?ref=[sha of the commit you want to use]"
  project_id = "[your stackit project id]"
  name       = "gh-actions-terraform"

  permissions = ["resourcemanager.project.get"]

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
| [stackit_authorization_folder_custom_role.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/authorization_folder_custom_role) | resource |
| [stackit_authorization_folder_role_assignment.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/authorization_folder_role_assignment) | resource |
| [stackit_authorization_organization_custom_role.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/authorization_organization_custom_role) | resource |
| [stackit_authorization_organization_role_assignment.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/authorization_organization_role_assignment) | resource |
| [stackit_authorization_project_custom_role.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/authorization_project_custom_role) | resource |
| [stackit_authorization_project_role_assignment.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/authorization_project_role_assignment) | resource |
| [stackit_service_account.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/service_account) | resource |
| [stackit_service_account_federated_identity_provider.github_actions](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/service_account_federated_identity_provider) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_assertions"></a> [additional\_assertions](#input\_additional\_assertions) | Additional assertions that are appended (combined with AND) to the "aud" and "sub" assertions of every federated identity provider, e.g. to further restrict access by "repository\_owner" or "workflow\_ref". | <pre>list(object({<br/>    item     = string<br/>    operator = string<br/>    value    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_custom_role_description"></a> [custom\_role\_description](#input\_custom\_role\_description) | Description of the custom role created from var.permissions. Defaults to a generated description mentioning the service account name. | `string` | `null` | no |
| <a name="input_federation_name_prefix"></a> [federation\_name\_prefix](#input\_federation\_name\_prefix) | Prefix used to build the name of the federated identity providers created for each entry in github\_subjects. | `string` | `"github-actions"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | ID of the STACKIT folder the custom role is created on and the roles are assigned on. Mutually exclusive with var.organization\_id. If neither is set, roles are created and assigned on var.project\_id. | `string` | `null` | no |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | The GitHub repository the service account should be usable from, in the form "org/repo", e.g. "digitalservicebund/terraform-modules". Also accepts the immutable subject format "org@org-id/repo@repo-id" used by repositories created after July 15, 2026 (or opted in to immutable subject claims), e.g. "digitalservicebund@123456/terraform-modules@456789". An optional leading "repo:" prefix is also accepted and won't be duplicated. | `string` | n/a | yes |
| <a name="input_github_subjects"></a> [github\_subjects](#input\_github\_subjects) | List of GitHub Actions OIDC token subject claim suffixes that are allowed to use the service account. Supported formats: "ref:refs/heads/<branch>", "ref:refs/tags/<tag>", "environment:<environment>" and "pull\_request". A separate, narrowly scoped federated identity provider is created for each entry. | `list(string)` | <pre>[<br/>  "ref:refs/heads/main"<br/>]</pre> | no |
| <a name="input_issuer"></a> [issuer](#input\_issuer) | The OIDC issuer URL of the identity provider. Defaults to GitHub's public OIDC issuer, override for GitHub Enterprise Server. | `string` | `"https://token.actions.githubusercontent.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the service account | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | ID of the STACKIT organization the custom role is created on and the roles are assigned on. Mutually exclusive with var.folder\_id. If neither is set, roles are created and assigned on var.project\_id. | `string` | `null` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | Permissions, e.g. ["iam.subject.get"], that are bundled into a custom role created by this module and assigned to the service account. Preferred over var.roles, because it allows granting least privilege. Can be combined with var.roles. | `list(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the STACKIT project that the service account is created in | `string` | n/a | yes |
| <a name="input_roles"></a> [roles](#input\_roles) | Existing roles to assign to the service account, e.g. ["editor"]. Custom roles are supported as well. Can be combined with var.permissions. Available roles (including custom ones) for a resource can be queried using stackit-cli: `stackit curl https://authorization.api.stackit.cloud/v2/<resourceType>/<resourceId>/roles`, e.g. `stackit curl https://authorization.api.stackit.cloud/v2/project/<project_id>/roles`. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_role_name"></a> [custom\_role\_name](#output\_custom\_role\_name) | Name of the custom role created from var.permissions, null if no permissions were supplied |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | ID of the resource (project, folder or organization) the custom role and role assignments are created on |
| <a name="output_role_scope"></a> [role\_scope](#output\_role\_scope) | The level (project, folder or organization) the custom role and role assignments are created on |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email of the created service account |
<!-- END_TF_DOCS -->
