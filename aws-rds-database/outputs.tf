output "endpoint" {
  value = module.db.db_instance_address
}

output "master_user_credentials_secret_arn" {
  value = module.db.db_instance_master_user_secret_arn
}
