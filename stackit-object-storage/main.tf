locals {
  yaml_autocreate_warning = <<-EOT
    ###
    # DO NOT EDIT MANUALLY
    # THIS FILE IS MANAGED BY TERRAFORM
    ###
  EOT
  access_codes = {
    "read-only"  = "ro"
    "read-write" = "rw"
    "superuser"  = "su"
  }

  roles_used = toset([for name, role in var.credentials : role])
  # Either the existing terraform credentials group URN or the newly created one
  terraform_credentials_group_urn = var.terraform_credentials_group_id != null ? data.stackit_objectstorage_credentials_group.existing_terraform_credentials_group[0].urn : stackit_objectstorage_credentials_group.terraform_credentials_group[0].urn
}

resource "stackit_objectstorage_bucket" "bucket" {
  project_id = var.project_id
  name       = var.bucket_name
}

data "stackit_objectstorage_credentials_group" "existing_terraform_credentials_group" {
  count                = var.terraform_credentials_group_id != null ? 1 : 0
  project_id           = var.project_id
  credentials_group_id = var.terraform_credentials_group_id
}

# Default terraform superuser credentials
resource "stackit_objectstorage_credentials_group" "terraform_credentials_group" {
  count = var.terraform_credentials_group_id == null ? 1 : 0
  # depends_on needed to avoid 409, because of simultaneously requests
  # REF: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket
  depends_on = [stackit_objectstorage_bucket.bucket]

  project_id = var.project_id
  name       = "${var.bucket_name}-cg"
}


resource "stackit_objectstorage_credential" "terraform_credentials" {
  count                = var.terraform_credentials_group_id == null ? 1 : 0
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.terraform_credentials_group[0].credentials_group_id
}

# Credentials requested by user with specific roles
resource "stackit_objectstorage_credentials_group" "user_credentials_group" {
  # depends_on needed to avoid 409, because of simultaneously requests
  # REF: https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/objectstorage_bucket
  depends_on = [stackit_objectstorage_bucket.bucket]

  for_each   = local.roles_used
  project_id = var.project_id
  name       = "${var.bucket_name}-${local.access_codes[each.key]}"
}

resource "stackit_objectstorage_credential" "credential" {
  for_each             = var.credentials
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.user_credentials_group[each.value].credentials_group_id
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = stackit_objectstorage_bucket.bucket.name
  policy = data.aws_iam_policy_document.combined_policy.json
}

data "aws_iam_policy_document" "combined_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.disable_access_for_other_credentials_groups.json,
    contains(local.roles_used, "read-only") ? data.aws_iam_policy_document.read_only[0].json : "",
    contains(local.roles_used, "read-write") ? data.aws_iam_policy_document.read_write[0].json : "",
  ]
}

data "aws_iam_policy_document" "disable_access_for_other_credentials_groups" {
  statement {
    effect = "Deny"
    not_principals {
      identifiers = concat([local.terraform_credentials_group_urn], [for cg in stackit_objectstorage_credentials_group.user_credentials_group : cg.urn])
      type        = "AWS"
    }
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${stackit_objectstorage_bucket.bucket.name}",
      "arn:aws:s3:::${stackit_objectstorage_bucket.bucket.name}/*"
    ]
  }
}

data "aws_iam_policy_document" "read_only" {
  count = contains(local.roles_used, "read-only") ? 1 : 0
  statement {
    effect = "Deny"
    principals {
      identifiers = [stackit_objectstorage_credentials_group.user_credentials_group["read-only"].urn]
      type        = "AWS"
    }
    actions = [
      "s3:Create*",
      "s3:Put*",
      "s3:Delete*",
      "s3:Restore*",
      "s3:Abort*",
    ]
    resources = [
      "arn:aws:s3:::${stackit_objectstorage_bucket.bucket.name}",
      "arn:aws:s3:::${stackit_objectstorage_bucket.bucket.name}/*"
    ]
  }
}


data "aws_iam_policy_document" "read_write" {
  count = contains(local.roles_used, "read-write") ? 1 : 0
  statement {
    effect = "Deny"
    principals {
      identifiers = [stackit_objectstorage_credentials_group.user_credentials_group["read-write"].urn]
      type        = "AWS"
    }
    actions = [
      "s3:CreateBucket",
      "s3:PutBucketPolicy",
      "s3:PutBucketTagging",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucket",
      "s3:PutEncryptionConfiguration",
      "s3:PutReplicationConfiguration",
      "s3:PutLifecycleConfiguration"
    ]
    resources = [
      "arn:aws:s3:::${stackit_objectstorage_bucket.bucket.name}",
      "arn:aws:s3:::${stackit_objectstorage_bucket.bucket.name}/*"
    ]
  }
}
