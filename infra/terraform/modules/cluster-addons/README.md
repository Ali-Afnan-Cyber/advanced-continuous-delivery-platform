# infra/terraform/modules/cluster-addons

The platform layer of the live K3s cluster, owned by Terraform: namespaces, cert-manager, and later
Sealed Secrets, Argo CD, Argo Rollouts and monitoring.

- The module has no provider blocks. `envs/local` configures the `kubernetes` and `helm` providers.
- Provider pins live in `envs/local/versions.tf`. This module only sets lower bounds.
