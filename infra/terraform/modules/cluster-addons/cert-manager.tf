locals {
  cert_manager_values = {
    # Install the CRDs with the chart, and keep them if the release is ever removed.
    crds = {
      enabled = true
      keep    = true
    }

    resources = {
      requests = { cpu = "10m", memory = "32Mi" }
      limits   = { cpu = "100m", memory = "128Mi" }
    }

    webhook = {
      resources = {
        requests = { cpu = "10m", memory = "32Mi" }
        limits   = { cpu = "100m", memory = "64Mi" }
      }
      # Standing rule: explicit probe timeouts, so a busy 2 vCPU VM does not restart pods.
      livenessProbe  = { timeoutSeconds = 10 }
      readinessProbe = { timeoutSeconds = 10 }
    }

    cainjector = {
      resources = {
        requests = { cpu = "10m", memory = "32Mi" }
        limits   = { cpu = "100m", memory = "128Mi" }
      }
    }

    # A one-time Job that checks the webhook answers before Helm reports success.
    startupapicheck = {
      resources = {
        requests = { cpu = "10m", memory = "32Mi" }
        limits   = { cpu = "200m", memory = "128Mi" }
      }
    }
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_chart_version

  # The namespace belongs to namespaces.tf, so Helm must not create it.
  namespace        = kubernetes_namespace_v1.this["cert-manager"].metadata[0].name
  create_namespace = false

  # Wait for all pods and for the startup check Job. Roll back if it fails.
  wait          = true
  wait_for_jobs = true
  atomic        = true
  timeout       = 600

  values = [yamlencode(local.cert_manager_values)]
}
