output "backup_bucket_name" {
  value = module.aws_local.backup_bucket_name
}

output "ssm_parameter_name" {
  value = module.aws_local.ssm_parameter_name
}

output "kms_key_id" {
  value = module.aws_local.kms_key_id
}
