module "iam" {
  source = "./modules/iam"

  child_accounts              = var.child_accounts
  namespace_to_aws_account_id = var.namespace_to_aws_account_id
  namespace                   = var.namespace
}