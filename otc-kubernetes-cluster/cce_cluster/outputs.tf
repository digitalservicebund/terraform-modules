output "node_security_group_id" {
  description = "Security group in which nodes get placed."
  value       = opentelekomcloud_cce_cluster_v3.this.security_group_node
}

output "kubeconfig" {
  description = "kubeconfig yaml for connecting to the cluster."
  value       = data.opentelekomcloud_cce_cluster_kubeconfig_v3.this.kubeconfig
}
