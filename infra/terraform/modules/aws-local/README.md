# infra/terraform/modules/aws-local

The AWS side of the platform, built in Floci. Three resources:

| Resource | Name | Use |
|----------|------|-----|
| S3 bucket | `acdp-backups` | database backups (Phase 14) |
| SSM parameter | `/acdp/local/emulator` | plain value, proves SSM works |
| KMS key | description only | proves KMS works |

- The module has no provider block. The caller sets the provider.
- Inputs: `name_prefix` (default `acdp`), `environment` (default `local`).
- Outputs: `backup_bucket_name`, `ssm_parameter_name`, `kms_key_id`.
