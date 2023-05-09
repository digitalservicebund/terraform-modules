output "access_key_id" {
  description = "Access key ID for the created user."
  value       = opentelekomcloud_identity_credential_v3.this.access
}

output "secret_access_key" {
  description = "Secret access key for the created user."
  value       = opentelekomcloud_identity_credential_v3.this.secret
}
