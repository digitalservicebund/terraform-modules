resource "aws_kms_key" "rds_database_kms_key" {
  description             = "This key is used to encrypt RDS database instances"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "rds_database_kms_alias" {
  target_key_id = aws_kms_key.rds_database_kms_key.id
  name          = "rds/database/${var.database_name}"
}