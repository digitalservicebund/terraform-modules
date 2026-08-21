# S3 Bucket (WORM / Object Lock)

# We intentionally manage bucket + policy directly here instead of reusing
# `stackit-object-storage`, because Telemetry Router needs a combined setup:
# object_lock at bucket creation time and a router-specific write-only IAM policy.
resource "stackit_objectstorage_bucket" "audit_logs" {
  project_id  = local.storage_project_id
  name        = "${var.name}-bucket"
  object_lock = true # Enables S3 Object Lock (required for WORM)
}

# Default bucket-level Object Lock configuration (WORM).
resource "aws_s3_bucket_object_lock_configuration" "worm" {
  bucket = stackit_objectstorage_bucket.audit_logs.name

  rule {
    default_retention {
      mode = var.object_lock_mode
      days = var.object_lock_days
    }
  }
}

# Lifecycle rule: automatically delete objects after the configured number of days.
# Should be set to a value >= object_lock_days so that objects can actually be deleted after the WORM retention expires.
resource "aws_s3_bucket_lifecycle_configuration" "expiration" {
  count  = var.lifecycle_expiration_days != null ? 1 : 0
  bucket = stackit_objectstorage_bucket.audit_logs.name

  rule {
    id     = "audit-log-expiration"
    status = "Enabled"

    expiration {
      days = var.lifecycle_expiration_days
    }
  }

  timeouts {
    create = "10m"
    update = "10m"
  }

  lifecycle {
    ignore_changes = [transition_default_minimum_object_size]
  }
}

resource "aws_s3_bucket_policy" "audit_logs" {
  bucket = stackit_objectstorage_bucket.audit_logs.name
  policy = data.aws_iam_policy_document.audit_logs.json
}

data "aws_iam_policy_document" "audit_logs" {
  # Deny everything for all principals except the two managed credentials groups.
  statement {
    sid    = "DenyOtherPrincipals"
    effect = "Deny"
    not_principals {
      type = "AWS"
      identifiers = [
        local.terraform_credentials_group_urn,
        stackit_objectstorage_credentials_group.router.urn,
      ]
    }
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${stackit_objectstorage_bucket.audit_logs.name}",
      "arn:aws:s3:::${stackit_objectstorage_bucket.audit_logs.name}/*",
    ]
  }

  # The router credentials group may only write (PutObject) – not read or delete.
  statement {
    sid    = "RouterWriteOnly"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = [stackit_objectstorage_credentials_group.router.urn]
    }
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:PutBucketPolicy",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucket",
      "s3:PutLifecycleConfiguration",
      "s3:PutObjectLegalHold",
      "s3:PutObjectRetention",
    ]
    resources = [
      "arn:aws:s3:::${stackit_objectstorage_bucket.audit_logs.name}",
      "arn:aws:s3:::${stackit_objectstorage_bucket.audit_logs.name}/*",
    ]
  }
}
