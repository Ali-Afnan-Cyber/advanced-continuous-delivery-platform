# infra/terraform/envs/local

Root module for the local environment. It sets the AWS provider (pointed at Floci on
`127.0.0.1:4566`, dummy credentials, path-style S3) and calls `modules/aws-local`.

    terraform -chdir=infra/terraform/envs/local init
    terraform -chdir=infra/terraform/envs/local plan
    terraform -chdir=infra/terraform/envs/local apply
    terraform -chdir=infra/terraform/envs/local test     # mock plan test, no Floci needed

## Versions

- `terraform` is pinned to 1.16.6 and the `aws` provider to 6.62.0. `.terraform.lock.hcl` is committed.

## State

- Backend: S3 in Floci. Bucket `acdp-tfstate`, key `local/terraform.tfstate`.
- Locking: `use_lockfile = true`. Terraform writes `local/terraform.tfstate.tflock` while it runs. No DynamoDB.
- The bucket is created by `scripts/tf-state-bootstrap.sh`, because Terraform cannot create its own state bucket.
- Copy the state outside the repo with `scripts/tf-state-backup.sh` (to `~/acdp-state-backups/terraform/`).
- State is never committed. `*.tfstate*` and `*.tfplan` are git-ignored.
