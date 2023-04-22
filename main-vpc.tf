module "main-vpc" {
  source               = "./modules/vpc"

  count = contains(["lab"], var.namespace) ? 1 : 0

  name = "main-vpc"
  vpc_cidr             = "10.0.0.0/16"
  private_subnets_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets_cidr  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  namespace            = var.namespace
  common_tags = local.common_tags
}