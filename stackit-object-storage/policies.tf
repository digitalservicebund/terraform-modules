
resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = var.enable_policy_creation ? 1 : 0
  bucket = stackit_objectstorage_bucket.bucket.name
  policy = data.aws_iam_policy_document.combined_policy.json
}

moved {
  from = aws_s3_bucket_policy.bucket_policy
  to   = aws_s3_bucket_policy.bucket_policy[0]
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
