# StackIT S3 Bucket Module

This module creates a STACKIT object storage bucket and credentials to access it.

## Usage

```hcl
module "object_storage_bucket" {
  source            = "github.com/digitalservicebund/terraform-modules//stackit-s3-bucket?ref=[sha of the commit you want to use]"
  project_id        = "[stackit project id]"
  bucket_name       = "[my-bucket-name]"
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >1.10.0  |
| <a name="requirement_stackit"></a> [stackit](#requirement_stackit)       | >=0.65.0 |

## Providers

| Name                                                         | Version  |
| ------------------------------------------------------------ | -------- |
| <a name="provider_stackit"></a> [stackit](#provider_stackit) | >=0.65.0 |

## Resources

| Name                                                                                                                                                                            | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [stackit_objectstorage_bucket.state_bucket](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket)                            | resource |
| [stackit_objectstorage_credential.credential](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credential)                      | resource |
| [stackit_objectstorage_credentials_group.credentials_group](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_credentials_group) | resource |

## Inputs

| Name                                                                                 | Description                                                             | Type           | Default                           | Required |
| ------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- | -------------- | --------------------------------- | :------: |
| <a name="input_bucket_name"></a> [bucket_name](#input_bucket_name)                   | The name of the bucket.                                                 | `string`       | n/a                               |   yes    |
| <a name="input_credentials_names"></a> [credentials_names](#input_credentials_names) | Names of credentials to create for the bucket. Defaults to ['default']. | `list(string)` | <pre>[<br/> "default"<br/>]</pre> |    no    |
| <a name="input_project_id"></a> [project_id](#input_project_id)                      | The ID of the project where the bucket will be created.                 | `string`       | n/a                               |   yes    |

## Outputs

| Name                                                                 | Description                          |
| -------------------------------------------------------------------- | ------------------------------------ |
| <a name="output_credentials"></a> [credentials](#output_credentials) | Credentials to access the S3 bucket. |

<!-- END_TF_DOCS -->
