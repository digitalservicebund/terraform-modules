# StackIT Object Storage Module

This module creates a STACKIT object storage bucket and credentials to access it. Its recommended to use it together with the
[STACKIT Secrets Manager Module](../stackit-secrets-manager) to store the credentials securely.

## Usage

With STACKIT Secrets Manager

```hcl
module "object_storage_bucket" {
  source      = "github.com/digitalservicebund/terraform-modules//stackit-object-storage?ref=[sha of the commit you want to use]"
  project_id  = "[stackit project id]"
  bucket_name = "[my-bucket-name]"

  manage_credentials         = true
  secret_manager_instance_id = "[instance id of your secrets manager (can be referenced from the stackit-secrets-manager module)]"
  kubernetes_namespace       = "[your-namespace]" # Namespace where the External Secret manifest will be applied
  external_secret_manifest   = "[path-to-the-manifest-file-to-be-created]" # The path in your system the external secret manifest will be stored at
}
```

Without STACKIT Secrets Manager

```hcl
module "object_storage_bucket" {
  source      = "github.com/digitalservicebund/terraform-modules//stackit-object-storage?ref=[sha of the commit you want to use]"
  project_id  = "[stackit project id]"
  bucket_name = "[my-bucket-name]"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.10.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >=2.6.1 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | >=0.65.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >=5.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.6.1 |
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | 0.68.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.6.0 |

## Resources

| Name | Type |
|------|------|
| [local_file.external_secret_manifest](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [stackit_objectstorage_bucket.bucket](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket) | resource |
| [stackit_objectstorage_credential.credential](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credential) | resource |
| [stackit_objectstorage_credentials_group.credentials_group](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credentials_group) | resource |
| [vault_kv_secret_v2.bucket_credentials](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the bucket. | `string` | n/a | yes |
| <a name="input_credentials_names"></a> [credentials\_names](#input\_credentials\_names) | Names of credentials to create for the bucket. Defaults to ['default']. | `list(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_external_secret_manifest"></a> [external\_secret\_manifest](#input\_external\_secret\_manifest) | Path where the external secret manifest will be stored at | `string` | `null` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes namespace where the External Secret manifest will be applied. | `string` | `null` | no |
| <a name="input_manage_credentials"></a> [manage\_credentials](#input\_manage\_credentials) | Set true to add the credentials into the STACKIT Secrets Manager. The credentials will be at `object-storage/[bucket name]/[credential name]` | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where the bucket will be created. | `string` | n/a | yes |
| <a name="input_secret_manager_instance_id"></a> [secret\_manager\_instance\_id](#input\_secret\_manager\_instance\_id) | Instance ID of the STACKIT Secret Manager, in which the database user password will be stored if manage\_credentials is true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | n/a |
| <a name="output_credentials"></a> [credentials](#output\_credentials) | Credentials to access the S3 bucket. Only available if `manage_credentials` is false |
<!-- END_TF_DOCS -->
