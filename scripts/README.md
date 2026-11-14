# scripts

Bash and Python helpers.

- `floci-verify.sh` smoke-tests the Floci emulator (S3, SSM, KMS round trips). Exit 0 means healthy.
- `tf-state-bootstrap.sh` creates the `acdp-tfstate` bucket in Floci. Safe to re-run.
- `tf-state-backup.sh` copies the Terraform state to `~/acdp-state-backups/terraform/` (outside the repo, mode 600). Run it before risky Terraform changes.
