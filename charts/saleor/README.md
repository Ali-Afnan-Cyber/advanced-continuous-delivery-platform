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

## Ingress

- Uses the Traefik that K3s ships. Do not install a second one.
- `ingress.hosts.api` and `ingress.hosts.dashboard` map to the `saleor-api` and `saleor-dashboard` Services.
- Phase 3 is plain HTTP on the `web` entrypoint. TLS is added in Phase 5.
- Local access: add both names to the Windows hosts file with the VM IP.

## Security settings

- `DEBUG` must stay `False`. `templates/guards.yaml` stops helm if it changes, or if the host lists below are empty.
- `ALLOWED_HOSTS` is the Django host check on the api. `ALLOWED_CLIENT_HOSTS` lists the dashboard and storefront hosts.
  Worker and scheduler need the second one too, because Saleor checks it at startup.
- Secret `saleor-app-secrets` is created outside the chart and never goes in Git. It holds `SECRET_KEY` and `RSA_PRIVATE_KEY`.
  api, worker and scheduler read both with `secretKeyRef`, so all three share the same values.
- The local copy of the RSA key lives in `.secrets/` (git-ignored, mode 600).
- Check: `/.well-known/jwks.json` on the api returns the public key made from `RSA_PRIVATE_KEY`.
