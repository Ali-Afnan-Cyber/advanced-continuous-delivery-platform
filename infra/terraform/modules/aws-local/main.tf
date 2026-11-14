# Bucket for database backups (used in Phase 14).
resource "aws_s3_bucket" "backups" {
  bucket = "${var.name_prefix}-backups"
}

# A plain, non-secret value. It proves SSM works. Real secrets use Sealed Secrets.
resource "aws_ssm_parameter" "emulator" {
  name  = "/${var.name_prefix}/${var.environment}/emulator"
  type  = "String"
  value = "floci"
}

# Key rotation is left out to keep the emulator calls simple.
resource "aws_kms_key" "main" {
  description             = "${var.name_prefix} ${var.environment} key"
  deletion_window_in_days = 7
}
