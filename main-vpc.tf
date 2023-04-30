module "main-vpc" {
  source = "./modules/vpc"

  count = contains([""], var.namespace) ? 1 : 0

  name                 = "main-vpc"
  vpc_cidr             = "10.0.0.0/16"
  az_to_subnets = {
    "us-east-1a" = { "public_cidr": "10.0.101.0/24", private_cidr: "10.0.1.0/24" }
    "us-east-1b" = { "public_cidr": "10.0.102.0/24", private_cidr: "10.0.2.0/24" }
  }
  namespace   = var.namespace
  common_tags = local.common_tags
}