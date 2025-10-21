# STACKIT Postgres Database Module

This module creates a managed Postgres database on STACKIT. Creates a database server instance, a database with the same
name and a user with the same username that is also the owner of the database.

This module can optionally store the database user password in the STACKIT Secrets Manager and provides a Kubernetes
External Secret manifest to fetch the credentials from there in the output. See documentation below for more details.

## Example

```hcl
module "database" {
  source         = "github.com/digitalservicebund/terraform-modules//stackit-postgres-db?ref=[sha of the commit you want to use]"
  project_id     = module.env.project_id
  name           = "my-database"
  cpu            = 2
  memory         = 4
  engine_version = "17"
  disk_size      = 5
  acls           = module.env.cluster_egress_range
}

# [OPTIONAL] Write the External Secret manifest to a file
resource "null_resource" "external_secret" {
  provisioner "local-exec" {
    command = <<-EOT
cat <<EOF > ../path/to/external-secret-manifest.yaml
${module.database.external_secret_manifest}
EOF
    EOT
  }
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
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | 0.68.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.3.0 |

## Resources

| Name | Type |
|------|------|
| [stackit_postgresflex_database.database](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/postgresflex_database) | resource |
| [stackit_postgresflex_instance.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/postgresflex_instance) | resource |
| [stackit_postgresflex_user.user](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/postgresflex_user) | resource |
| [vault_kv_secret_v2.postgres_credentials](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acls"></a> [acls](#input\_acls) | List of ACL IDs to associate with the database instance. This should be the cluster Egress IP Range only! | `list(string)` | n/a | yes |
| <a name="input_backup_schedule"></a> [backup\_schedule](#input\_backup\_schedule) | Backup schedule in cron format. Defaults to daily at 3am UTC. | `string` | `"0 3 * * *"` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Specifies the CPU specs of the instance. Available Options: 2, 4, 8 & 16 | `number` | n/a | yes |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of the instance disk volume. Its value range is from 5 GB to 4000 GB. | `number` | n/a | yes |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Specifies the storage performance class. e.g. premium-perf6-stackit | `string` | `"premium-perf6-stackit"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Specifies the postgres version. | `string` | `"17"` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes namespace where the External Secret manifest will be applied. | `string` | `"[your-namespace]"` | no |
| <a name="input_manage_user_password"></a> [manage\_user\_password](#input\_manage\_user\_password) | Set true to add the user password into the STACKIT Secrets Manager. | `bool` | `true` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Specifies the memory (RAM) specs of the instance in GB. Available Options: 4, 8, 16, 32 & 128 | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of the Postgres instance. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the STACKIT project where the bucket will be created. | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of read replicas for the instance. | `number` | `1` | no |
| <a name="input_secret_manager_instance_id"></a> [secret\_manager\_instance\_id](#input\_secret\_manager\_instance\_id) | Instance ID of the STACKIT Secret Manager, in which the database user password will be stored if manage\_user\_password is true. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | Database host address |
| <a name="output_external_secret_manifest"></a> [external\_secret\_manifest](#output\_external\_secret\_manifest) | Kubernetes External Secret manifest to fetch the database credentials from STACKIT Secrets Manager |
| <a name="output_password"></a> [password](#output\_password) | Database password. This will be emtpy if the password is managed in STACKIT Secrets Manager. |
| <a name="output_secret_manager_secret_name"></a> [secret\_manager\_secret\_name](#output\_secret\_manager\_secret\_name) | Name of the secret in STACKIT Secrets Manager where the database credentials are stored |
| <a name="output_username"></a> [username](#output\_username) | Database username |
<!-- END_TF_DOCS -->
