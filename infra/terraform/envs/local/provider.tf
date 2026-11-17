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

# The live K3s cluster. The kubeconfig belongs to the VM user (mode 600).
locals {
  kubeconfig = pathexpand("~/.kube/config")
}

provider "kubernetes" {
  config_path = local.kubeconfig
}

# Helm provider 3.x takes the cluster settings as an attribute, not a block.
provider "helm" {
  kubernetes = {
    config_path = local.kubeconfig
  }
}
