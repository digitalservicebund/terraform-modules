module "object_storage" {
  source      = "../stackit-s3-bucket"
  project_id  = var.project_id
  bucket_name = var.state_bucket_name
}
