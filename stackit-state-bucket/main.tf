module "object_storage" {
  source      = "../stackit-object-storage"
  project_id  = var.project_id
  bucket_name = var.state_bucket_name
}
