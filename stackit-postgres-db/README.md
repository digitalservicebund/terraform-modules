# STACKIT Postgres Database Module

This module provisions a managed PostgreSQL database instance on STACKIT. It handles the creation of the instance, databases, and users, while optionally integrating with STACKIT Secrets Manager for secure credential storage.

## Configuration Logic

To minimize configuration for simple use cases, this module uses "Convention over Configuration" with fallback logic:

| Resource | Logic |
| :--- | :--- |
| **Databases** | Creates databases listed in `database_names`. <br> *Fallback:* If the list is empty, creates a single database named after the instance (`var.name`). |
| **Admin User** | Creates an admin user named `admin_user`. <br> *Fallback:* If not set, creates a user named after the instance (`var.name`). |

## Usage Example

```hcl
 module "database" {
  source         = "github.com/digitalservicebund/terraform-modules//stackit-postgres-db?ref=[sha of the commit you want to use]"
  project_id     = "[your stackit project id]"
  name           = "[database instance name]"
  cpu            = 2
  memory         = 4
  engine_version = "17"
  disk_size      = 5
  acls           = "[cluster egress range]" # Ask the platform team for the correct egress range

  database_names = ["list-of-names", "to-create-databases"] # optional, will fallback to `var.name` if not present
  admin_name     = "root" # optional, will fallback to `var.name` if not present
  user_names     = ["additional", "user"] # optional

  secret_manager_instance_id = "[your secrets manager instance id]" # available as output from stackit-secrets-manager module
  kubernetes_namespace       = "[your-namespace]" # Namespace where the External Secret manifest will be applied
  external_secret_manifest   = "[path-to-the-manifest-file-to-be-created]" # The path in your system the external secret manifest will be stored at
  config_map_manifest        = "[patth-to-the-manifestt-file-to-be-created" # The path in your system the config map manifest will be stored at
} 
```

## Secrets & Kubernetes Integration

If `manage_user_password` is set to `true` (default):

1.  **Vault Storage:** The module generates strong passwords and stores them in your STACKIT Secrets Manager instance.
2.  **Manifest Generation:** It generates a local YAML file containing an `ExternalSecret` resource.
3.  **Kubernetes Sync:** You can apply this manifest to your cluster. The External Secrets Operator will then fetch the credentials from Secrets Manager

## Kubernetes Config Maps

If `config_map_manifest` is set, then the module will also create a manifest file with the following contents per defined databases:

- database: <name of database>
- host: <host of database instance>
- port: <port of database instance>

When the variable is not set, the manifest will not be created.

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
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.3.0 |

## Resources

| Name | Type |
|------|------|
| [local_file.config_map_manifest](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.external_secret_manifest](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [stackit_postgresflex_database.database](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/postgresflex_database) | resource |
| [stackit_postgresflex_instance.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/postgresflex_instance) | resource |
| [stackit_postgresflex_user.admin](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/postgresflex_user) | resource |
| [stackit_postgresflex_user.user](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/postgresflex_user) | resource |
| [vault_kv_secret_v2.postgres_admin_credentials](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [vault_kv_secret_v2.postgres_user_credentials](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acls"></a> [acls](#input\_acls) | List of ACL IDs to associate with the database instance. This should be the cluster Egress IP Range only! | `list(string)` | n/a | yes |
| <a name="input_admin_name"></a> [admin\_name](#input\_admin\_name) | Specified the name of the Postgres Database Owner | `string` | `null` | no |
| <a name="input_backup_schedule"></a> [backup\_schedule](#input\_backup\_schedule) | Backup schedule in cron format. Defaults to daily at 3am UTC. | `string` | `"0 3 * * *"` | no |
| <a name="input_config_map_manifest"></a> [config\_map\_manifest](#input\_config\_map\_manifest) | Path where the config map manifest will be stored at | `string` | `null` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Specifies the CPU specs of the instance. Available Options: 2, 4, 8 & 16 | `number` | n/a | yes |
| <a name="input_database_names"></a> [database\_names](#input\_database\_names) | List of database names to create. If empty, defaults to a single database named after the instance. | `set(string)` | `[]` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of the instance disk volume. Its value range is from 5 GB to 4000 GB. | `number` | n/a | yes |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Specifies the storage performance class. e.g. premium-perf6-stackit | `string` | `"premium-perf6-stackit"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Specifies the postgres version. | `string` | `"17"` | no |
| <a name="input_external_secret_manifest"></a> [external\_secret\_manifest](#input\_external\_secret\_manifest) | Path where the external secret manifest will be stored at | `string` | `null` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes namespace where the External Secret manifest will be applied. | `string` | `null` | no |
| <a name="input_manage_user_password"></a> [manage\_user\_password](#input\_manage\_user\_password) | Set true to add the user password into the STACKIT Secrets Manager. | `bool` | `true` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Specifies the memory (RAM) specs of the instance in GB. Available Options: 4, 8, 16, 32 & 128 | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of the Postgres instance. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the STACKIT project where the database will be created. | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of read replicas for the instance. | `number` | `1` | no |
| <a name="input_secret_manager_instance_id"></a> [secret\_manager\_instance\_id](#input\_secret\_manager\_instance\_id) | Instance ID of the STACKIT Secret Manager, in which the database user password will be stored if manage\_user\_password is true. | `string` | `""` | no |
| <a name="input_user_names"></a> [user\_names](#input\_user\_names) | List of additional database users to create. Elements must be unique. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | Database host address |
| <a name="output_credentials"></a> [credentials](#output\_credentials) | Map of user keys to passwords. Empty if managed in Secrets Manager. |
| <a name="output_secret_manager_secret_names"></a> [secret\_manager\_secret\_names](#output\_secret\_manager\_secret\_names) | List of secret paths created in STACKIT Secrets Manager |
<!-- END_TF_DOCS -->