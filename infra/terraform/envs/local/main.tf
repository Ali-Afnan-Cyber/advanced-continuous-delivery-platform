module "aws_local" {
  source = "../../modules/aws-local"
}

module "cluster_addons" {
  source = "../../modules/cluster-addons"
}
