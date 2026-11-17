locals {
  # Every namespace the platform owns. The value is the environment label, or "" for none.
  namespaces = {
    "saleor-dev"     = "dev"
    "saleor-staging" = "staging"
    "saleor-prod"    = "prod"
    "argocd"         = ""
    "argo-rollouts"  = ""
    "monitoring"     = ""
    "cert-manager"   = ""
    "sealed-secrets" = ""
  }
}

resource "kubernetes_namespace_v1" "this" {
  for_each = local.namespaces

  metadata {
    name = each.key
    labels = merge(
      { "app.kubernetes.io/part-of" = "acdp" },
      each.value == "" ? {} : { environment = each.value },
    )
  }

  # Deleting a namespace deletes everything in it, including database volumes.
  lifecycle {
    prevent_destroy = true
  }
}
