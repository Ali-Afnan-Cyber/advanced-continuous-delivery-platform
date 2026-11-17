# Task 3.2 connection check: a read-only lookup proves Terraform reaches the cluster.
# Task 3.3 replaces this file with the namespaces.
data "kubernetes_namespace_v1" "kube_system" {
  metadata {
    name = "kube-system"
  }
}
