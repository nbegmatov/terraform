module "bastion" {
  source                     = "./modules/bastion"
  count = contains(["lab"], var.namespace) ? 1 : 0
  name = "bastion-host"
  namespace                  = var.namespace
  vpc_id = module.main-vpc[0].vpc_id
  common_tags = local.common_tags
  public_subnet_ids = module.main-vpc[0].public_subnet_ids
  main_zone_id = data.aws_route53_zone.main_zone.zone_id
  depends_on = [module.main-vpc[0]]
}