variable "child_accounts" {}
variable "namespace_to_aws_account_id" {}
variable "namespace" {}

locals {
  root_enabled      = var.namespace == "root"
  lab_enabled       = var.namespace == "lab"
  prod_enabled      = var.namespace == "root"
  groups_users_list = flatten([for groups, users in var.groups_users : flatten([for user in users : { group = groups, user = user }])])                      # list of maps of groups and user, ex: {"group" = "devops" , "user" = "amukkamala" }
  role_to_policy    = flatten([for role, policies in var.role_to_policy["${var.namespace}"] : [for policy in policies : { role = role, policy = policy, }]]) # list of maps of roles and policies, ex: {"policy" = "IAMReadOnlyAccess", "role" = "Devops"}
}

variable "groups_users" {
  type = map(any)
  default = {
    developers = ["mroof", "hhufford", "egreigman", "tnguyen", "jaldrich"]
    devops     = ["nbegmatov", "amukkamala", "wgraham"]
    admins     = ["gcolburn", "vgoodman", "cmartinez", "munwin", "tina-dev"]
  }
}

variable "role_to_policy" {
  type = map(any)
  default = {
    root = {},
    prod = {
      "Devops" = [
        "AdministratorAccess",
        "AWSSupportAccess",
        "IAMReadOnlyAccess"
      ],
      "Developers" = [
        "IAMReadOnlyAccess",
        "AWSSupportAccess",
        "IAMUserSSHKeys",
        "PowerUserAccess"
      ],
      "Admins" = [
        "AdministratorAccess",
        "AWSSupportAccess"
      ]
    },
    lab = {
      "Admins" = [
        "AdministratorAccess"
      ],
      "Devops" = [
        "AdministratorAccess"
      ],
      "Developers" = [
        "PowerUserAccess"
      ]
    }
  }
}
