# StackIT Terraform State Backend Module
This module creates a terraform state backend on StackIT using Object Storage.

## Usage
1. Execute the module in your terraform configuration
2. The content  of a `backend.tf` file will be available as output from the module
3. The credentials for this backend will be available as outputs from the module
4. [Optional] The content of a `.envrc` file is also available as output and contains the credentials for the bucket 

## Example
```hcl
module "backend_bucket" {
  source            = "github.com/digitalservicebund/terraform-modules//stackit-state-bucket?ref=[sha of the commit you want to use]"
  project_id        = "[stackit project id]"
  state_bucket_name = "ds-state-bucket-[project name]"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.10.0 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | >=0.65.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | >=0.65.0 |

## Resources

| Name | Type |
|------|------|
| [stackit_objectstorage_bucket.state_bucket](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket) | resource |
| [stackit_objectstorage_credential.state_bucket_credential](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credential) | resource |
| [stackit_objectstorage_credentials_group.state_bucket_group](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credentials_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where the bucket will be created. | `string` | n/a | yes |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | The name of the state bucket. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key"></a> [access\_key](#output\_access\_key) | Access key id to access the backend bucket. Export this value as AWS\_ACCESS\_KEY\_ID to access the bucket. |
| <a name="output_backend_file"></a> [backend\_file](#output\_backend\_file) | Content of the backend configuration file for Terraform. |
| <a name="output_envrc_file"></a> [envrc\_file](#output\_envrc\_file) | Content of the .envrc file to set environment variables for accessing the backend bucket. |
| <a name="output_secret_access_key"></a> [secret\_access\_key](#output\_secret\_access\_key) | Secret access key to access the backend bucket. Export this value as AWS\_SECRET\_ACCESS\_KEY to access the bucket. |
<!-- END_TF_DOCS -->