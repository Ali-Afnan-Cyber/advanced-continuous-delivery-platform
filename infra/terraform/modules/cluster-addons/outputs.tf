output "cluster_check_uid" {
  description = "UID of kube-system. A value here means Terraform can read the cluster."
  value       = data.kubernetes_namespace_v1.kube_system.metadata[0].uid
}
