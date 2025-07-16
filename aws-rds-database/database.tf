module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.database_name

  engine                   = "postgres"
  engine_version           = var.engine_major_version
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  family                   = "postgres${var.engine_major_version}"
  major_engine_version     = var.engine_major_version
  instance_class           = var.instance_class

  allocated_storage     = 20
  max_allocated_storage = 100

  kms_key_id = aws_kms_key.rds_database_kms_key.key_id

  db_name  = var.db_name
  username = var.username
  port     = 5432

  manage_master_user_password = true

  multi_az               = true
  db_subnet_group_name   = var.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 7
  deletion_protection     = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
}
