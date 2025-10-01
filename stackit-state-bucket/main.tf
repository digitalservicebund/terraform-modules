resource "stackit_objectstorage_bucket" "state_bucket" {
  project_id = var.project_id
  name       = var.state_bucket_name
}

resource "stackit_objectstorage_credentials_group" "state_bucket_group" {
  # depends_on needed to avoid 409, because of simultaneously requests
  # REF: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket
  depends_on = [stackit_objectstorage_bucket.state_bucket]
  project_id = var.project_id
  name       = "${var.state_bucket_name}-cg"
}

resource "stackit_objectstorage_credential" "state_bucket_credential" {
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.state_bucket_group.credentials_group_id
}
