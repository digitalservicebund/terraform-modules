resource "aws_dynamodb_table" "terraform_lock_table" {
  name     = "terraform-state-lock"
  hash_key = "LockID"

  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}
