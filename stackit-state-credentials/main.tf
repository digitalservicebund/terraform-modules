data "onepassword_vault" "employee" {
  name = "Employee"
}

resource "onepassword_item" "bucket_credentials" {
  vault = data.onepassword_vault.employee.uuid
  title = "${var.state_bucket_name} credentials"
  category = "secure_note"

  section {
    label = "Credentials"
    field {
      label = "ACCESS_KEY_ID"
      value = var.access_key
      type = "STRING"
    }
    field {
      label = "SECRET_ACCESS_KEY"
      value = var.secret_access_key
      type = "STRING"
    }
  }
}
