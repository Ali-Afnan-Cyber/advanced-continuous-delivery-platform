output "backup_bucket_name" {
  value = aws_s3_bucket.backups.bucket
}

output "ssm_parameter_name" {
  value = aws_ssm_parameter.emulator.name
}

output "kms_key_id" {
  value = aws_kms_key.main.key_id
}
