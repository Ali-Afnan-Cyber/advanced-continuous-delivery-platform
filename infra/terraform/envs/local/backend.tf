terraform {
  backend "s3" {
    bucket = "acdp-tfstate"
    key    = "local/terraform.tfstate"
    region = "us-east-1"

    # Floci runs on this VM. The credentials are dummy values.
    access_key     = "test"
    secret_key     = "test"
    use_path_style = true
    endpoints = {
      s3 = "http://127.0.0.1:4566"
    }

    # Locking: a .tflock object next to the state, made with a conditional write.
    use_lockfile = true

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
