mock_provider "aws" {}

run "names_follow_the_prefix" {
  command = plan

  assert {
    condition     = output.backup_bucket_name == "acdp-backups"
    error_message = "Backup bucket must be named acdp-backups."
  }

  assert {
    condition     = output.ssm_parameter_name == "/acdp/local/emulator"
    error_message = "SSM parameter path must be /acdp/local/emulator."
  }
}
