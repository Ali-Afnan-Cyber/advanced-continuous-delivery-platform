# charts/saleor

Helm chart for the ACDP Saleor platform on single-node K3s (namespace `saleor-dev`).

## Contents

| Component | Template | Phase |
|-----------|----------|-------|
| postgres (StatefulSet, headless Service) | `postgres-*.yaml` | 2, moved in 3 |
| cache / Valkey (Deployment, ClusterIP Service) | `cache-*.yaml` | 2, moved in 3 |
| api (Deployment) | `api-deployment.yaml` | 3, Task 2 |
| worker (Deployment) | `worker-deployment.yaml` | 3, Task 3 |
| scheduler (Deployment, exactly 1 replica) | `scheduler-deployment.yaml` | 3, Task 3 |
| dashboard | added in Phase 3 tasks | 3 |
| storefront | added later | 9 |

## Rules

- No secrets in this chart. Only `secretKeyRef` and secret names.
- Every pod has requests, limits, and probes. Pods run non-root with a read-only root filesystem.
- All tunables live in `values.yaml`.

## Use

    helm lint charts/saleor
    helm template saleor charts/saleor -n saleor-dev
    helm upgrade --install saleor charts/saleor -n saleor-dev

## Dashboard

- Image `ghcr.io/saleor/saleor-dashboard:3.23.39`, 1 replica, plain Deployment (no canary).
- `dashboard.apiUrl` sets `API_URL`. The browser calls it, so it is the public api name.
- The image's start script edits `/app/dashboard/index.html`. An init container copies the
  bundle into an emptyDir so the pod can run as uid 101 with a read-only root filesystem.
- Needs no secrets. `dashboard.writablePaths` are emptyDir mounts for nginx temp files.
- Starting resources: 16Mi request, 64Mi limit.
