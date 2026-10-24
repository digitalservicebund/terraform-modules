# STACKIT Postgres Database Module

This module provisions a managed PostgreSQL database instance on STACKIT. It handles the creation of the instance, databases, and users, while integrating with STACKIT Secrets Manager for secure credential storage.

## Prerequisites

Before you use this module you need:

1. You have used the [infra-template](https://github.com/digitalservicebund/infra-template) to create your own infra repo and followed the README there.
2. A **STACKIT Secrets Manager instance**, created with the [`stackit-secrets-manager`](../stackit-secrets-manager) Terraform module. The database passwords are written into it, so it must exist first. Its `instance_id` output feeds `secret_manager_instance_id`.

## Configuration Logic

To minimize configuration for simple use cases, this module uses "[Convention over Configuration](https://en.wikipedia.org/wiki/Convention_over_configuration)" with fallback logic:

| Resource           | Logic                                                                                                                                                       |
| :----------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Databases**      | Creates databases listed in `database_names`. <br> _Fallback:_ If the list is empty, creates a single database named after the instance (`var.name`).        |
| **Admin User**     | Creates an admin user named `admin_user.name` with the roles `login` and `createdb`. <br> _Fallback:_ If not set, creates a user named after the instance (`var.name`). <br> See [Admin vs. application users](#admin-vs-application-users). |
| **Database Owner** | Each database is owned by the admin user. <br> _Override:_ Set `owner_of = "<database name>"` on an entry in `additional_users` to make that user the owner instead. <br> See [Admin vs. application users](#admin-vs-application-users). |
| **Secret paths**   | Credentials are stored at `postgres/<username>` in Secrets Manager. <br> _Override:_ Set `secret_manager_path` on the user.                                   |

Additional users are created with the `login` role only. They cannot create databases.

## Admin vs. application users

The admin user is privileged: it has the `createdb` role and, by default, owns every database the module creates. Treat it accordingly.

- **Use the admin user for schema migrations and manual work only.** This is the account your migration tool (Flyway, Prisma Migrate, Hibernate/Rails/Django DDL) should authenticate with, plus the occasional break-glass session.
- **Use an additional user for application access.** Create one `additional_users` entry per application and let the running application connect with it. Additional users only get the `login` role, so they cannot create databases.
- **Do not expose the admin credentials to the application container.** The generated Kubernetes Secret contains the credentials of *all* users, so restrict the volume `items` in your Deployment to the two keys of the app user (see [Wiring it up with Kubernetes](#wiring-it-up-with-kubernetes)).
- **Run migrations as a separate step.** An init container can mount the admin credentials while the application Pod itself never sees them. Your mileage may vary.

### A note on `owner_of`

Setting `owner_of = "<database name>"` on an entry in `additional_users` makes that user the owner of that database instead of the admin user. The owner has full control over the database and its objects, so such a user is no longer limited to plain application access, it can also perform DDL on the database it owns. Whether that is desirable depends on how you split migrations and runtime access.

## Usage Example

Add to your `main.tf`:

```hcl
module "database" {
  source         = "github.com/digitalservicebund/terraform-modules?ref=stackit-postgres-db/vX.Y.Z"
  project_id     = "[your stackit project id]"
  name           = "[database instance name]"
  flavor_id      = "2.4"                # see "Choosing a flavor" below
  engine_version = "17"
  disk_size      = 5                    # GB, between 5 and 4000
  retention_days = 32                   # optional, defaults to 32, must be between 32 and 90
  acls           = ["X.X.X.X/32"]       # cluster egress CIDR, see "Network access" below

  database_names   = ["databaseA", "databaseB"]  # optional, falls back to `var.name`
  admin_user       = { name = "migrator" }       # optional, falls back to `var.name`. Migrations and DDL only.
  additional_users = [{ name = "app" }]          # optional, runtime application access

  secret_manager_instance_id = module.secrets_manager.instance_id             # output of the stackit-secrets-manager module
  kubernetes_namespace       = "[your-namespace]"                             # namespace of the generated ExternalSecret and ConfigMap
  external_secret_store_name = "[your-secret-store-name]"                     # optional, defaults to "secret-store"
  external_secret_manifest   = "../../manifests/base/db-external-secret.yaml" # where the ExternalSecret manifest is written
  config_map_manifest        = "../../manifests/base/db-config-map.yaml"      # optional, where the ConfigMap manifest is written

  # Set the following two variables to enable Postgres Flex metrics scraping in Prometheus.
  # The values for non-prod and production are available here: https://platform-docs.prod.tech.digitalservice.dev/stackit-user-docs/how-to-guides/postgres-flex-metrics-scraping
  metrics_role_id  = "[postgres_flex_metrics_role_id]"  # optional, organization-wide role ID for Postgres Flex Prometheus Metrics Reader. Required if `metrics_sa_email` is set.
  metrics_sa_email = "[postgres_flex_metrics_sa_email]" # optional, Service Account email for Postgres Flex Metrics Service Account from STACKIT Platform Project. Required if `metrics_role_id` is set.
}
```

### Choosing a flavor

`flavor_id` is the STACKIT machine size of the instance. It encodes both the hardware and the number of nodes:

| Value           | vCPU | RAM   | Nodes                  |
| :-------------- | :--- | :---- | :--------------------- |
| `"2.4"`         | 2    | 4 GB  | 1                      |
| `"2.4-replica"` | 2    | 4 GB  | 3 (primary + 2 replicas) |
| `"4.16"`        | 4    | 16 GB | 1                      |
| `"4.16-replica"`| 4    | 16 GB | 3 (primary + 2 replicas) |

So the number before the dot is CPU cores, the number after it is RAM in GB, and the `-replica` suffix is what decides high availability. This is the only way to set the node count, the module has no separate `replicas` variable.

Two things to keep in mind:

- The valid `cpu.ram` combinations are defined by STACKIT, you cannot pick arbitrary pairs. Check the Postgres Flex flavor list in the STACKIT portal (or `stackit postgresflex flavor list`) for what your project can use.
- Switching an existing instance between a non-replica and a `-replica` flavor changes the node count and is a disruptive operation. Plan it like a migration, not like a routine change.

### Network access

A Postgres Flex instance only accepts connections from the IP ranges listed in `acls`. Traffic from your pods leaves the Kubernetes cluster through a fixed egress address, so `acls` must contain exactly that range and nothing else.

## Secrets Manager and Kubernetes Integration

If `manage_user_password` is set to `true` (the default):

1. **Vault Storage:** The module generates strong passwords and stores them in your STACKIT Secrets Manager instance.
2. **Manifest Generation:** It generates a local YAML file containing an `ExternalSecret` resource.
3. **Kubernetes Sync:** You apply this manifest to your cluster. The External Secrets Operator then fetches the credentials from Secrets Manager and materializes them as a Kubernetes Secret.

With `manage_user_password = true` you **must** also set `external_secret_manifest` and `kubernetes_namespace`, otherwise the apply fails with a precondition error.

Declare the vault provider in your `terraform.tf`:

```hcl
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">=5.3.0"
    }
  }
}
```

And add the provider configuration to your `provider.tf`:

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

## Applying this Module

Then run Terraform locally (not in the CI) for it to create local files, that need to get checked into your infra repo.

### Generated Manifests

The module writes the `external_secret_manifest` and `config_map_manifest` files itself. Both files carry a `DO NOT EDIT MANUALLY` header, are owned by Terraform, and should be committed to your infra repo. They contain references to secrets, never secret values.

#### ExternalSecret

Written to `external_secret_manifest`. The resulting Kubernetes Secret is always named **`database-credentials`** and contains two keys per user:

| Key                   | Value                        |
| :-------------------- | :--------------------------- |
| `<username>_user`     | the Postgres username        |
| `<username>_password` | the generated password       |

#### ConfigMap

Written to `config_map_manifest`. If the variable is not set, no ConfigMap is generated. One ConfigMap per database is created, named **`database-config-<database name>`**, with these keys:

| Key             | Value                            |
| :-------------- | :------------------------------- |
| `database.host` | host of the database instance    |
| `database.name` | name of the database             |
| `database.port` | port of the database instance    |


### Run Terraform

1. `cd terraform/<stage>`
2. `op run - terraform init` to download the module.
3. `op run - terraform plan` to review.
4. `op run - terraform apply` to create resources on STACKIT and to write the two manifests.

### Wiring it up with Kubernetes

Add both files to your `manifests/base/kustomization.yaml`:

```yaml
resources:
  - db-external-secret.yaml
  - db-config-map.yaml
```

And consume them from your deployment. Non-sensitive values come from the ConfigMap as env vars, credentials are mounted as a volume. Injecting secrets via `env`/`envFrom` (`secretKeyRef`) is [blocked by a Kyverno policy](https://platform-docs.prod.tech.digitalservice.dev/stackit-user-docs/how-to-guides/kyverno-policy-violations#disallow-secrets-as-env-vars-policy) on the cluster, so your application has to read the credentials from the mounted files.

```yaml
containers:
  - name: my-app
    env:
      - name: DB_HOST
        valueFrom:
          configMapKeyRef:
            name: database-config-my-database
            key: database.host
      - name: DB_NAME
        valueFrom:
          configMapKeyRef:
            name: database-config-my-database
            key: database.name
      - name: DB_PORT
        valueFrom:
          configMapKeyRef:
            name: database-config-my-database
            key: database.port
      - name: SECRETS_FILE_PATH
        value: /etc/secrets
    volumeMounts:
      - name: database-credentials
        mountPath: /etc/secrets/database
        readOnly: true
volumes:
  - name: database-credentials
    secret:
      secretName: database-credentials
      # Only expose the app user, not the admin (migrator) credentials
      items:
        - key: app_user
          path: app_user
        - key: app_password
          path: app_password
```

The container then reads `/etc/secrets/database/app_user` and `/etc/secrets/database/app_password`.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >1.10.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >=2.6.1 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | >=0.105.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >=5.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | >=2.6.1 |
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | >=0.105.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | >=5.3.0 |

## Resources

| Name | Type |
|------|------|
| [local_file.config_map_manifest](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.external_secret_manifest](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [stackit_authorization_project_role_assignment.postgres_flex_metrics_access](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/authorization_project_role_assignment) | resource |
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
| <a name="input_additional_users"></a> [additional\_users](#input\_additional\_users) | List of additional database users to create. Names must be unique. Example: [{ name = "user1", secret\_manager\_path = "custom/path/user1" }, { name = "user2" }]. If secret\_manager\_path is omitted for a user, a default path is used. | <pre>list(object({<br/>    name                = string<br/>    secret_manager_path = optional(string)<br/>    owner_of            = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_admin_user"></a> [admin\_user](#input\_admin\_user) | Specified the name of the Postgres Database Owner and (optionally) a custom Secret Manager path. Example: { name = "admin", secret\_manager\_path = "custom/path/admin" }. If secret\_manager\_path is omitted, a default path is used. If admin\_user is not specified, a user with the same name as the instance will be created. | <pre>object({<br/>    name                = string<br/>    secret_manager_path = optional(string)<br/>  })</pre> | <pre>{<br/>  "name": null<br/>}</pre> | no |
| <a name="input_backup_schedule"></a> [backup\_schedule](#input\_backup\_schedule) | Backup schedule in cron format. Defaults to daily at 3am UTC. | `string` | `"0 3 * * *"` | no |
| <a name="input_config_map_manifest"></a> [config\_map\_manifest](#input\_config\_map\_manifest) | Path where the config map manifest will be stored at | `string` | `null` | no |
| <a name="input_database_names"></a> [database\_names](#input\_database\_names) | List of database names to create. If empty, defaults to a single database named after the instance. | `set(string)` | `[]` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size of the instance disk volume. Its value range is from 5 GB to 4000 GB. | `number` | n/a | yes |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Specifies the storage performance class. e.g. premium-perf6-stackit | `string` | `"premium-perf6-stackit"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Specifies the postgres version. | `string` | `"17"` | no |
| <a name="input_external_secret_manifest"></a> [external\_secret\_manifest](#input\_external\_secret\_manifest) | Path where the external secret manifest will be stored at | `string` | `null` | no |
| <a name="input_external_secret_store_name"></a> [external\_secret\_store\_name](#input\_external\_secret\_store\_name) | Name of the Kubernetes SecretStore referenced by the generated ExternalSecret. | `string` | `"secret-store"` | no |
| <a name="input_flavor_id"></a> [flavor\_id](#input\_flavor\_id) | Postgres Flex flavor ID. Format: '<cpu>.<ram>' for 1 replica, '<cpu>.<ram>-replica' for 3 replicas. Examples: "2.4", "2.4-replica", "4.16", "4.16-replica". | `string` | n/a | yes |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes namespace where the External Secret manifest will be applied. | `string` | `null` | no |
| <a name="input_manage_user_password"></a> [manage\_user\_password](#input\_manage\_user\_password) | Set true to add the user password into the STACKIT Secrets Manager. | `bool` | `true` | no |
| <a name="input_metrics_role_id"></a> [metrics\_role\_id](#input\_metrics\_role\_id) | Organization-wide Role ID for Postgres Flex Prometheus Metrics Reader | `string` | `null` | no |
| <a name="input_metrics_sa_email"></a> [metrics\_sa\_email](#input\_metrics\_sa\_email) | Service account email for Postgres Flex Metrics Service Account from STACKIT Platform Project | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Specifies the name of the Postgres instance. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the STACKIT project where the database will be created. | `string` | n/a | yes |
| <a name="input_retention_days"></a> [retention\_days](#input\_retention\_days) | Backup retention in days. Must be between 32 and 90. | `number` | `32` | no |
| <a name="input_secret_manager_instance_id"></a> [secret\_manager\_instance\_id](#input\_secret\_manager\_instance\_id) | Instance ID of the STACKIT Secret Manager, in which the database user password will be stored if manage\_user\_password is true. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | Database host address |
| <a name="output_credentials"></a> [credentials](#output\_credentials) | Map of user keys to passwords. Empty if managed in Secrets Manager. |
| <a name="output_secret_manager_secret_names"></a> [secret\_manager\_secret\_names](#output\_secret\_manager\_secret\_names) | List of secret paths created in STACKIT Secrets Manager |
<!-- END_TF_DOCS -->
