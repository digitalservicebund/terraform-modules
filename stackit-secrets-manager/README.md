# StackIT Secrets Manager Module
This module creates a STACKIT Secrets Manager in your project with credentials for terraform and external secrets operator.

## Example
```hcl
module "secrets_manager" {
  source     = "github.com/digitalservicebund/terraform-modules//stackit-secrets-manager?ref=[sha of the commit you want to use]"
  project_id = module.env.project_id
  name       = "digitalcheck-secrets"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.10.0 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | >=0.65.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >=5.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | >=0.65.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | >=5.3.0 |

## Resources

| Name | Type |
|------|------|
| [stackit_secretsmanager_instance.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/secretsmanager_instance) | resource |
| [stackit_secretsmanager_user.external_secrets](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/secretsmanager_user) | resource |
| [stackit_secretsmanager_user.terraform](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/secretsmanager_user) | resource |
| [vault_generic_endpoint.config](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_max_versions"></a> [max\_versions](#input\_max\_versions) | Specifies how many previous secret versions are retained. | `number` | `3` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the secrets manager instance | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the project that the secrets manager is created in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_secrets_password"></a> [external\_secrets\_password](#output\_external\_secrets\_password) | Password to be used by external secrets provider |
| <a name="output_external_secrets_username"></a> [external\_secrets\_username](#output\_external\_secrets\_username) | Username to be used by external secrets provider |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Instance ID of the secrets manager instance |
| <a name="output_terraform_password"></a> [terraform\_password](#output\_terraform\_password) | Password to be used by terraform. |
| <a name="output_terraform_username"></a> [terraform\_username](#output\_terraform\_username) | Username to be used by terraform. |
<!-- END_TF_DOCS -->