module "kubernetes" {
  source = "./modules/kubernetes"

  count = contains(["lab"], var.namespace) ? 1 : 0

  name               = "yurtah"
  vpc_id             = module.main-vpc[0].vpc.id
  public_subnet_ids  = module.main-vpc[0].public_subnet_ids
  private_subnet_ids = module.main-vpc[0].private_subnet_ids

  depends_on = [module.main-vpc]
}
