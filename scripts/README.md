# scripts

Bash and Python helpers.

- `floci-verify.sh` smoke-tests the Floci emulator (S3, SSM, KMS round trips). Exit 0 means healthy.
- `tf-state-bootstrap.sh` creates the `acdp-tfstate` bucket in Floci. Safe to re-run.
- `tf-state-backup.sh` copies the Terraform state to `~/acdp-state-backups/terraform/` (outside the repo, mode 600). Run it before risky Terraform changes.
- `pg-dump.sh` dumps the Saleor database into the Floci bucket `acdp-backups` (key `postgres/<namespace>/saleor-<UTC time>.dump`). Custom format, restore with `pg_restore`. Phase 11 adds the daily job and retention.
