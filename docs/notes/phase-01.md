# Phase 3: Saleor services on K3s

## How I would explain it

The Saleor app runs as a Helm chart in the `saleor-dev` namespace. It has four
Saleor Deployments (api, worker, scheduler, dashboard), a Valkey Deployment, and
Postgres as a StatefulSet. The chart holds no secrets. The database password,
SECRET_KEY and the RSA key come from Kubernetes Secrets through `secretKeyRef`.

Traefik, which K3s ships, is the ingress. It reads one Ingress object and sends
`api-dev.cdp.test` to the api Service and `dash-dev.cdp.test` to the dashboard
Service. It matches on the Host header, so an unknown host gets a 404. Phase 3
is plain HTTP. TLS comes in Phase 5. On my Windows PC the hosts file maps both
names to the VM IP.

With DEBUG=False, Saleor is strict. `ALLOWED_HOSTS` must list the api host, or
Django answers 400 (this happened through the Ingress). `ALLOWED_CLIENT_HOSTS`
must list the dashboard and storefront hosts, and it is checked at startup, so
the worker and scheduler need it too. JWT tokens are signed with the RSA key, so
all three workloads must share the same `RSA_PRIVATE_KEY` and `SECRET_KEY`. A
guard template stops Helm if DEBUG is not False or the host lists are empty.

`populatedb` loads demo products, categories and a default channel. It is not
idempotent, so it runs once as a Job. `createsuperuser` creates the admin who
logs in to the dashboard. The password lives in a git-ignored file.

The scheduler is fixed at one replica with strategy Recreate, so two Celery beat
processes can never run together.

## Measured

- VM memory used: 48% (target under 85%)
- api: 584Mi (limit 1Gi), worker: 309Mi (limit 768Mi), scheduler: 299Mi (limit 512Mi)
- populatedb Job duration: 5m 44s (2026-11-11T16:41:42Z to 2026-11-11T16:47:26Z)
- Products in DB: 29
- api /graphql/ GET: 200, dashboard: 200, unknown host: 404
- Dashboard login: works

## Known gaps

- Product images are missing. Media is an emptyDir per pod, so it is not shared.
- Helm on the VM is v3.22.1, TECHNICAL.md pins v4.3.0. Not upgraded mid-phase.
