# Floci runs on this VM, outside K3s, on loopback only.
# The credentials are dummy values. Never put real keys here.
locals {
  floci = "http://127.0.0.1:4566"
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3  = local.floci
    ssm = local.floci
    kms = local.floci
  }
}
