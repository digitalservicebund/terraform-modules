# Encrypted Remote State Bucket and Table to lock state

Creates an encrypted S3 Bucket and a DynamoDB Table to store your terraform remote state and state lock in AWS.

# Usage

```hcl
module "terraform_backend" {
  source            = "github.com/digitalservicebund/terraform-modules//aws-remote-state?ref=2b28a10d66261ca8f6b6663bc2356aea49ed5040"
}


# This creates the backend.tf file so that you can use `terraform init` to initialize the remote state
resource "null_resource" "backend_config" {
  provisioner "local-exec" {
    command = <<-EOT
echo '${module.terraform_backend.backend_tfile}' > backend.tf
    EOT
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~ 5.97 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~ 5.97 |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform_lock_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_kms_key.terraform_s3_bucket_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.terraform_state_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.bootstrap_s3_bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dynamo_db_table_name"></a> [dynamo\_db\_table\_name](#input\_dynamo\_db\_table\_name) | Name of the DynamoDB Table used for state locking. Defaults to terraform-state-lock. | `string` | `"terraform-state-lock"` | no |
| <a name="input_state_bucket_name"></a> [state\_bucket\_name](#input\_state\_bucket\_name) | Name of the S3 bucket to store Terraform state. If not provided a unique name will be generated. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_tfile"></a> [backend\_tfile](#output\_backend\_tfile) | The content of the backend.tf file that should be created to use this remote state |
<!-- END_TF_DOCS -->