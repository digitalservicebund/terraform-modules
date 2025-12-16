# STACKIT Credential Manifest Module

This module creates a credential pair (user/password) with a random password that is stored in the provided STACKIT Secrets Manager.
It will also create a manifest file to be used by Kubernetes so you can expose the credentials to your services.

## Example

```hcl
locals {
  db_users = toset(["poweruser", "reader"])
}


module "my_users" {
  source   = "github.com/digitalservicebund/terraform-modules//stackit-credential-manifest?ref=[sha of the commit you want to use]"
  
  for_each = local.db_users
  vault_name                 = "postgres"
  user                       = each.key
  manifest_name              = "database-${each.key}-credentials" 
  manifest_file              = "../../manifests/overlays/staging-stackit/database-${each.key}-secret.yaml"
  secret_manager_instance_id = local.secret_manager_instance_id
  kubernetes_namespace       = local.kubernetes_namespace
}

```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.10.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >=2.6.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.7.2 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >=5.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.6.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.6.0 |

## Resources

| Name | Type |
|------|------|
| [local_file.external_secret_manifest](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [vault_kv_secret_v2.credentials](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes namespace where the External Secret manifest will be applied. | `string` | `"[your-namespace]"` | no |
| <a name="input_manifest_file"></a> [manifest\_file](#input\_manifest\_file) | Path to the new file | `string` | n/a | yes |
| <a name="input_manifest_name"></a> [manifest\_name](#input\_manifest\_name) | Kubernetes MetaData Name property | `string` | n/a | yes |
| <a name="input_secret_manager_instance_id"></a> [secret\_manager\_instance\_id](#input\_secret\_manager\_instance\_id) | Instance ID of the STACKIT Secret Manager, in which the database user password will be stored if manage\_user\_password is true. | `string` | `""` | no |
| <a name="input_user"></a> [user](#input\_user) | Specifies the user the credentials are created for | `string` | n/a | yes |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | Specifies the Vault name the credentials will be stored under | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_manager_secret_name"></a> [secret\_manager\_secret\_name](#output\_secret\_manager\_secret\_name) | Name of the secret in STACKIT Secrets Manager where the credentials are stored |
<!-- END_TF_DOCS -->