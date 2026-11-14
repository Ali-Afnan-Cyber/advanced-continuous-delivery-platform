# infra/terraform/envs/local

Root module for the local environment. It sets the AWS provider (pointed at Floci on
`127.0.0.1:4566`, dummy credentials, path-style S3) and calls `modules/aws-local`.

    terraform -chdir=infra/terraform/envs/local init
    terraform -chdir=infra/terraform/envs/local plan
    terraform -chdir=infra/terraform/envs/local apply
    terraform -chdir=infra/terraform/envs/local test     # mock plan test, no Floci needed

- `terraform` is pinned to 1.16.6 and the `aws` provider to 6.62.0. `.terraform.lock.hcl` is committed.
- State is never committed. `*.tfstate*` and `*.tfplan` are git-ignored.
