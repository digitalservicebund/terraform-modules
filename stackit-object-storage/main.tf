resource "stackit_objectstorage_bucket" "state_bucket" {
  project_id = var.project_id
  name       = var.bucket_name
}

resource "stackit_objectstorage_credentials_group" "credentials_group" {
  # depends_on needed to avoid 409, because of simultaneously requests
  # REF: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket
  depends_on = [stackit_objectstorage_bucket.state_bucket]
  project_id = var.project_id
  name       = "${var.bucket_name}-cg"
}

resource "stackit_objectstorage_credential" "credential" {
  for_each             = toset(var.credentials_names)
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.credentials_group.credentials_group_id
}
