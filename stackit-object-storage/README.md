# StackIT Object Storage Module

This module creates a STACKIT object storage bucket and credentials to access it. It is recommended to use it together
with the
[STACKIT Secrets Manager Module](../stackit-secrets-manager) to store the credentials securely.

By default, two credentials are created:

- `default` with `superuser` role to be used by your application
- `terraform` with a role to be used by terraform to manage the bucket. This role does not have access to the content of
  the bucket.

> 💡 In case you already have another bucket in your terraform configuration, you should provide the
`terraform_credentials_group_id` input variable to let terraform manage the bucket with the existing credentials group.

The module is also creating polices that restrict access to the bucket only to the created credentials (and the
credentials group identified by `terraform_credentials_group_id` to manage the bucket). If you want to create your own
policies (e.g. in case you need public access), you can disable this behavior by setting the `enable_policy_creation`
input variable to `false`. Please note that in this case all credentials in the same STACKIT project will have access to
your bucket.

## Usage

### AWS Provider Configuration

To manage access policies on the bucket, you need to configure the `aws` provider:

```hcl
provider "aws" {
  region                      = "eu01"
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  access_key = module.backend_bucket.access_key
  secret_key = module.backend_bucket.secret_access_key

  endpoints {
    s3 = "https://object.storage.eu01.onstackit.cloud"
  }
}
```

### With STACKIT Secrets Manager

```hcl
module "object_storage_bucket" {
  source                         = "github.com/digitalservicebund/terraform-modules//stackit-object-storage?ref=[sha of the commit you want to use]"
  project_id                     = "[stackit project id]"
  bucket_name                    = "[my-bucket-name]"
  terraform_credentials_group_id = "[credentials group id used by terraform to manage the bucket (can be referenced from the stackit-state-bucket module)]"

  manage_credentials         = true
  secret_manager_instance_id = "[instance id of your secrets manager (can be referenced from the stackit-secrets-manager module)]"
  kubernetes_namespace = "[your-namespace]" # Namespace where the External Secret manifest will be applied
  external_secret_manifest   = "[path-to-the-manifest-file-to-be-created]"
  # The path in your system the external secret manifest will be stored at
}

```

Add the vault provider config to your `provider.tf` file to integrate with the STACKIT Secrets Manager:

```hcl
provider "vault" {
  address          = "https://prod.sm.eu01.stackit.cloud"
  skip_child_token = true

  auth_login_userpass {
    username = module.secrets_manager.terraform_username
    password = module.secrets_manager.terraform_password
  }
}
```

### Without STACKIT Secrets Manager

```hcl
module "object_storage_bucket" {
  source                         = "github.com/digitalservicebund/terraform-modules//stackit-object-storage?ref=[sha of the commit you want to use]"
  project_id                     = "[stackit project id]"
  bucket_name                    = "[my-bucket-name]"
  terraform_credentials_group_id = "[credentials group id used by terraform to manage the bucket (can be referenced from the stackit-state-bucket module)]"
}
```

### Generating multiple credentials

The module supports the generation of multiple credentials with different roles. You can specify the credentials to be
created using the `credentials` input variable.

For example, to create two read-only credentials in addition to the default superuser credential:

```hcl
module "object_storage_bucket" {
  source                         = "github.com/digitalservicebund/terraform-modules//stackit-object-storage?ref=[sha of the commit you want to use]"
  project_id                     = "[stackit project id]"
  bucket_name                    = "[my-bucket-name]"
  terraform_credentials_group_id = "[credentials group id used by terraform to manage the bucket (can be referenced from the stackit-state-bucket module)]"


  credentials = {
    # <name> = <role>
    default = "superuser"
    team1   = "read-only"
    team2   = "read-only"
  }
}
```  

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=6.28.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >=2.6.1 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | >=0.65.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >=5.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.6.1 |
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | 0.68.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket_lifecycle_configuration.bucket_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [local_file.external_secret_manifest](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [stackit_objectstorage_bucket.bucket](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket) | resource |
| [stackit_objectstorage_credential.credential](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credential) | resource |
| [stackit_objectstorage_credential.terraform_credentials](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credential) | resource |
| [stackit_objectstorage_credentials_group.terraform_credentials_group](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credentials_group) | resource |
| [stackit_objectstorage_credentials_group.user_credentials_group](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credentials_group) | resource |
| [vault_kv_secret_v2.bucket_credentials](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [aws_iam_policy_document.combined_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.disable_access_for_other_credentials_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.read_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [stackit_objectstorage_credentials_group.existing_terraform_credentials_group](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/data-sources/objectstorage_credentials_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the bucket. | `string` | n/a | yes |
| <a name="input_credentials"></a> [credentials](#input\_credentials) | Credentials to create for the bucket. Map of credential name to role (e.g. { name = role }. Valid roles are: superuser, read-only, read-write. | `map(string)` | <pre>{<br/>  "default": "superuser"<br/>}</pre> | no |
| <a name="input_enable_manifest_creation"></a> [enable\_manifest\_creation](#input\_enable\_manifest\_creation) | Set to true to create an External Secret manifest for Kubernetes to access the created credentials. | `bool` | `true` | no |
| <a name="input_enable_policy_creation"></a> [enable\_policy\_creation](#input\_enable\_policy\_creation) | Set to false in case you want to create your own policy. WARNING: If you disable this, all credentials in the same STACKIT project have access to your bucket. | `bool` | `true` | no |
| <a name="input_external_secret_manifest"></a> [external\_secret\_manifest](#input\_external\_secret\_manifest) | Path where the external secret manifest will be stored at | `string` | `null` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes namespace where the External Secret manifest will be applied. | `string` | `null` | no |
| <a name="input_lifecycle_days"></a> [lifecycle\_days](#input\_lifecycle\_days) | Lifespan of stored data. Data will be deleted after specified value in days. Default value is null (no automatic deletion) | `number` | `null` | no |
| <a name="input_manage_credentials"></a> [manage\_credentials](#input\_manage\_credentials) | Set true to add the credentials into the STACKIT Secrets Manager. The credentials will be at `object-storage/[bucket name]/[credential name]` | `bool` | `false` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where the bucket will be created. | `string` | n/a | yes |
| <a name="input_secret_manager_instance_id"></a> [secret\_manager\_instance\_id](#input\_secret\_manager\_instance\_id) | Instance ID of the STACKIT Secret Manager, in which the database user password will be stored if manage\_credentials is true. | `string` | `null` | no |
| <a name="input_terraform_credentials_group_id"></a> [terraform\_credentials\_group\_id](#input\_terraform\_credentials\_group\_id) | ID of the credentials group that is used by Terraform to manage the bucket. A credential of this credential group must be used in the AWS provider config. If not provided, a new credentials group will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | n/a |
| <a name="output_credentials"></a> [credentials](#output\_credentials) | Credentials to access the S3 bucket. Only available if `manage_credentials` is false |
| <a name="output_terraform_credentials"></a> [terraform\_credentials](#output\_terraform\_credentials) | Credentials to manage buckets via Terraform. Use these credentials when configuring the AWS provider. This will be empty if `terraform_credentials_group_id` is provided. |
| <a name="output_terraform_credentials_group_id"></a> [terraform\_credentials\_group\_id](#output\_terraform\_credentials\_group\_id) | The ID of the credentials group used by Terraform to manage the S3 bucket. |
<!-- END_TF_DOCS -->
