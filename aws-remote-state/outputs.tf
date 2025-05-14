output "backend_tfile" {
  value       = <<-EOT
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.terraform_state_bucket.bucket}"
    kms_key_id     = "${aws_kms_key.terraform_s3_bucket_kms_key.arn}"
    key            = "tfstate-backend"
    region         = "${aws_s3_bucket.terraform_state_bucket.region}"
    dynamodb_table = "${aws_dynamodb_table.terraform_lock_table.name}"
    encrypt        = true
  }
}
    EOT
  description = "The content of the backend.tf file that should be created to use this remote state"
}
