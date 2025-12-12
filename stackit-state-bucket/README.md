# StackIT Terraform State Backend Module

This module creates a terraform state backend on StackIT using Object Storage. It is supposed to be used to
bootstrap your terraform configuration by setting up the remote state for you.

## Features

- Creates an object storage bucket to store the terraform state in
- Creates a `backend.tf` file to configure the terraform backend with this bucket
- Creates a 1Password entry in the users vault to store the bucket credentials
- Creates a `.envrc` file to referencing the credentials in 1Password

## Usage

1. Add the module to your terraform folder
   ```hcl
   module "backend_bucket" {
     source            = "github.com/digitalservicebund/terraform-modules//stackit-state-bucket?ref=[sha of the commit you want to use]"
     project_id        = "[stackit project id]"
     state_bucket_name = "ds-state-bucket-[project name]"
   }
   ```
2. Run `terraform init` and `terraform apply`
3. A `backend.tf` should have been generated in your terraform folder
4. A `.envrc` file should have been generated in your terraform folder
5. A 1Password item should have been generated in your vault
6. Run `terraform init` to migrate your local state to the remote state bucket

You can disable all the magic with inputs.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.10.0 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | >=0.65.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_object_storage"></a> [object\_storage](#module\_object\_storage) | ../stackit-object-storage | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.backend_config](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.envrc_file](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.onepassword](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_onepassword_item"></a> [create\_onepassword\_item](#input\_create\_onepassword\_item) | Create a 1Password item containing the credentials for the state bucket. Needs the 1Password CLI. | `bool` | `true` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where the bucket will be created. | `string` | n/a | yes |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | The name of the state bucket. | `string` | n/a | yes |
| <a name="input_write_backend_config_file"></a> [write\_backend\_config\_file](#input\_write\_backend\_config\_file) | Write the backend.tf file containing the configuration to connect to the state bucket. | `bool` | `true` | no |
| <a name="input_write_envrc_file"></a> [write\_envrc\_file](#input\_write\_envrc\_file) | Write a .envrc file containing the environment variables to read the state bucket credentials from 1Password. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key"></a> [access\_key](#output\_access\_key) | Access key id to access the backend bucket. Export this value as AWS\_ACCESS\_KEY\_ID to access the bucket. |
| <a name="output_backend_file"></a> [backend\_file](#output\_backend\_file) | Content of the backend configuration file for Terraform. |
| <a name="output_envrc_file"></a> [envrc\_file](#output\_envrc\_file) | Content of the .envrc file to set environment variables for accessing the backend bucket. |
| <a name="output_onepassword_command"></a> [onepassword\_command](#output\_onepassword\_command) | The 1Password CLI command that needs to be executed to add the bucket credentials to 1Password. |
| <a name="output_secret_access_key"></a> [secret\_access\_key](#output\_secret\_access\_key) | Secret access key to access the backend bucket. Export this value as AWS\_SECRET\_ACCESS\_KEY to access the bucket. |
<!-- END_TF_DOCS -->
