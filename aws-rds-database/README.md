# Terraform RDS Database Module

This module provides a Terraform configuration to create an RDS database instance on AWS with KMS key for encryption and
security group to manage access to it.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                            | Version |
| --------------------------------------------------------------- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement_aws)          | ~> 5.97 |
| <a name="requirement_random"></a> [random](#requirement_random) | ~> 3.7  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 5.97 |

## Modules

| Name                                                                          | Source                                   | Version |
| ----------------------------------------------------------------------------- | ---------------------------------------- | ------- |
| <a name="module_db"></a> [db](#module_db)                                     | terraform-aws-modules/rds/aws            | n/a     |
| <a name="module_security_group"></a> [security_group](#module_security_group) | terraform-aws-modules/security-group/aws | ~> 5.0  |

## Resources

| Name                                                                                                                          | Type     |
| ----------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_kms_alias.rds_database_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.rds_database_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)       | resource |

## Inputs

| Name                                                                                             | Description                                                                                                           | Type     | Default                | Required |
| ------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------- | :------: |
| <a name="input_database_name"></a> [database_name](#input_database_name)                         | Name of the RDS database to be created. Will also be used to name related resources.                                  | `string` | n/a                    |   yes    |
| <a name="input_database_subnet_group"></a> [database_subnet_group](#input_database_subnet_group) | Name of the database subnet group to be used for the RDS instance.                                                    | `string` | n/a                    |   yes    |
| <a name="input_db_name"></a> [db_name](#input_db_name)                                           | Name of the database that will be created in the RDS instance.                                                        | `string` | `"digitalservicebund"` |    no    |
| <a name="input_engine_major_version"></a> [engine_major_version](#input_engine_major_version)    | Major version of the RDS database engine to be used. E.g., '14', '15', etc.                                           | `string` | n/a                    |   yes    |
| <a name="input_ingress_cidr_block"></a> [ingress_cidr_block](#input_ingress_cidr_block)          | CIDR block to allow ingress traffic to the RDS database. This should be the CIDR block of the VPC or the VPC Peering. | `string` | n/a                    |   yes    |
| <a name="input_instance_class"></a> [instance_class](#input_instance_class)                      | Instance class for the RDS database. E.g., 'db.t4g.micro', 'db.t3.medium', etc.                                       | `string` | n/a                    |   yes    |
| <a name="input_username"></a> [username](#input_username)                                        | Master username for the RDS database. Avoid using reserved words like 'user'.                                         | `string` | `"digitalservicebund"` |    no    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                              | ID of the VPC where the RDS database will be created.                                                                 | `string` | n/a                    |   yes    |

## Outputs

| Name                                                                                                                                      | Description |
| ----------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_endpoint"></a> [endpoint](#output_endpoint)                                                                               | n/a         |
| <a name="output_master_user_credentials_secret_arn"></a> [master_user_credentials_secret_arn](#output_master_user_credentials_secret_arn) | n/a         |

<!-- END_TF_DOCS -->
