resource "opentelekomcloud_obs_bucket" "this" {
  bucket = var.bucket_name
  acl    = "public-read"
  versioning = var.versioning_enabled
  user_domain_names = var.user_domain_names

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    resource_group = var.resource_group
  }
}

resource "opentelekomcloud_obs_bucket_policy" "this" {
  bucket = opentelekomcloud_obs_bucket.this.id
  policy = <<POLICY
{
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "ID": ["*"]
    },
    "Action": [
      "GetObject"
    ],
    "Resource": [
      "${opentelekomcloud_obs_bucket.this.bucket}/*"
    ]
  }]
}
POLICY
}
