output "namespace_names" {
  description = "Names of the namespaces Terraform owns."
  value       = sort(keys(kubernetes_namespace_v1.this))
}
