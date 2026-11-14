# Phase 4: AWS emulator and Terraform state

## How I would explain it

Floci is a local AWS emulator. It runs as one Docker container on the VM, outside K3s, and listens on 127.0.0.1:4566. It speaks the S3, SSM and KMS APIs, so the normal AWS CLI and the normal Terraform AWS provider work against it with dummy credentials (test / test). Its data sits on the Docker volume `floci-data`, so a restart keeps everything.

Terraform reaches Floci through the aws provider. The provider points S3, SSM and KMS at the Floci address, uses path-style S3 URLs, and skips the checks that would call real AWS. The module `aws-local` creates three things: the bucket `acdp-backups`, the parameter `/acdp/local/emulator` and a KMS key. The provider lives in `envs/local`, not in the module, so the module stays reusable and the same root can hold the helm and kubernetes providers in Phase 5.

Terraform state lives in the Floci bucket `acdp-tfstate`, key `local/terraform.tfstate`. Terraform cannot create its own state bucket, so `scripts/tf-state-bootstrap.sh` makes it with the AWS CLI. Locking uses `use_lockfile`. Terraform writes a `.tflock` object next to the state with a conditional write (If-None-Match). If the object exists, S3 answers 412 and the second run stops. No DynamoDB.

State can hold secrets. `scripts/tf-state-backup.sh` pulls a copy to `~/acdp-state-backups/terraform/`, outside the repo (folder mode 700, files mode 600).

## Result

- Terraform S3 backend with lockfile works against Floci: yes. The second conditional write is refused, and Terraform refuses to plan while a lock object exists.
- MinIO fallback: not needed.

## Measured

- Terraform: Terraform v1.16.6. AWS provider: 6.62.0. AWS CLI: aws-cli/2.40.1.
- Docker (Ubuntu apt): Docker version 29.1.3, build 29.1.3-0ubuntu3~24.04.2
- Floci memory: 81.37MiB / 512MiB
- VM memory used: 51% (target under 85%)
- State object size: 6355 bytes, 3 resources
- Second plan: no changes. State and buckets survive a Floci restart.

## Known gaps

- KMS key rotation is not enabled. Not tested against Floci.
- The SSM parameter is a plain String. Secrets use Sealed Secrets (Phase 6).
- The aws provider pin (6.62.0) is not in the TECHNICAL.md section 3 table yet.
