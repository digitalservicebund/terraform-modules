# STACKIT Postgres Database Module

This module creates a managed Postgres database on STACKIT.

## Example

```hcl
module "database" {
  source     = "github.com/digitalservicebund/terraform-modules//stackit-postgres-db?ref=[sha of the commit you want to use]"
  project_id = module.env.project_id
  name       = "my-database"
  cpu        = 2
  memory     = 4
  version    = "17"
  disk_size  = 5
  acl        = module.env.cluster_egress_range
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
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | 0.68.0 |

## Resources

| Name | Type |
|------|------|
| [stackit_postgresflex_instance.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/postgresflex_instance) | resource |
| [stackit_postgresflex_user.user](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/postgresflex_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acls"></a> [acls](#input\_acls) | List of ACL IDs to associate with the database instance. This should be the cluster Egress IP Range only! | `list(string)` | n/a | yes |
| <a name="input_backup_schedule"></a> [backup\_schedule](#input\_backup\_schedule) | Backup schedule in cron format. Defaults to daily at 3am UTC. | `string` | `"0 3 * * *"` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Specifies the CPU specs of the instance. Available Options: 2, 4, 8 & 16 | `number` | n/a | yes |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of the instance disk volume. Its value range is from 5 GB to 4000 GB. | `number` | n/a | yes |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Specifies the storage performance class. e.g. premium-perf6-stackit | `string` | `"premium-perf6-stackit"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Specifies the postgres version. | `string` | `"17"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Specifies the memory (RAM) specs of the instance in GB. Available Options: 4, 8, 16, 32 & 128 | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of the Postgres instance. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the STACKIT project where the bucket will be created. | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of read replicas for the instance. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | Database host address |
| <a name="output_password"></a> [password](#output\_password) | Database password |
<!-- END_TF_DOCS -->
