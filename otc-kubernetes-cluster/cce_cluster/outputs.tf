output "cluster_id" {
  description = "The ID of the cluster."
  value       = opentelekomcloud_cce_cluster_v3.this.id
}

output "node_security_group_id" {
  description = "Security group in which nodes get placed."
  value       = opentelekomcloud_cce_cluster_v3.this.security_group_node
}
