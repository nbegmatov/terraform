module "iam" {
  source                     = "./modules/iam"
  child_accounts             = var.child_accounts
  account_name_to_account_id = var.account_name_to_account_id
  namespace                  = var.namespace
}