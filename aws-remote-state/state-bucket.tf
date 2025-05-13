data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_kms_key" "terraform_s3_bucket_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket_prefix = "terraform-remote-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bootstrap_s3_bucket_encryption" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_s3_bucket_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
