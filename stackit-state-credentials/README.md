# Stackit State Bucket Credentials in 1Password

This module stores the credentials for a STACKIT terraform state bucket in 1Password so that you can access it using the
1Password CLI when running terraform.

## Usage
This module is designed to work with the [stackit-state-bucket](../stackit-state-bucket) module. You can use it as follows:

### Steps
1. Add the `stackit-state-bucket` module to your terraform configuration to create the state bucket
2. Add the `stackit-state-credentials` module to store the credentials in 1Password
3. Use the output of the `stackit-state-credentials` module to create a `.envrc` file for accessing the state bucket via 1Password CLI
4. Apply everything & verify that the credentials are stored in 1Password
5. Replace the module call with a `removed` block 
6. Run terraform apply to remove the 1Password item from the terraform state but keep it in 1Password

### Example

```hcl
module "state_bucket_credentials" {
  source = "github.com/digitalservicebund/terraform-modules//stackit-state-credentials?ref=[sha of the commit you want to use]"             
    access_key        = module.backend_bucket.access_key
    secret_access_key = module.backend_bucket.secret_access_key
    state_bucket_name = module.backend_bucket.state_bucket_name
}

# OPTIONAL: generate .envrc file to access the backend bucket via 1Password CLI
resource "null_resource" "envrc" {
  provisioner "local-exec" {
    command = <<-EOT
echo '${module.state_bucket_credentials.envrc_file}' > .envrc
    EOT
  }
}
```

### ⚠️ Important!
We do not use 1Password in our GitHub Actions pipeline. Therefore, you have to remove this module before running terraform in GitHub Actions.

```hcl

# Replace your module call with the removed block to keep the credentials in 1Password but avoid destroying them when running terraform.
removed {
  from = module.state_bucket_credentials.onepassword_item.bucket_credentials
  lifecycle {
    destroy = false # This prevents Terraform from deleting the actual 1Password item when you remove the module
  }
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.10.0 |
| <a name="requirement_onepassword"></a> [onepassword](#requirement\_onepassword) | >=2.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_onepassword"></a> [onepassword](#provider\_onepassword) | 2.2.1 |

## Resources

| Name | Type |
|------|------|
| [onepassword_item.bucket_credentials](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/resources/item) | resource |
| [onepassword_vault.employee](https://registry.terraform.io/providers/1Password/onepassword/latest/docs/data-sources/vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | The access key for the state bucket to be stored in 1Password | `string` | n/a | yes |
| <a name="input_secret_access_key"></a> [secret\_access\_key](#input\_secret\_access\_key) | The secret access key for the state bucket to be stored in 1Password | `string` | n/a | yes |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | The name of the state bucket | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_envrc_file"></a> [envrc\_file](#output\_envrc\_file) | Content of the .envrc file to set environment variables for accessing the backend bucket via 1Password. |
<!-- END_TF_DOCS -->