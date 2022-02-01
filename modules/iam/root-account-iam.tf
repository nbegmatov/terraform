resource "aws_iam_group_policy" "assume-role-in-child-account" {
  for_each = local.root_enabled ? toset([for k, v in var.groups_users : k]) : []
  name        = "GrantAccessTo${title(each.key)}RoleInChildAccounts"
  group = aws_iam_group.groups[each.key].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sts:AssumeRole"]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${var.account_name_to_account_id["lab"]}:role/lab-${title(each.key)}-access-role"
      },
      {
        Action   = ["sts:AssumeRole"]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${var.account_name_to_account_id["prod"]}:role/prod-${title(each.key)}-access-role"
      }
    ]
  })
}

resource "aws_iam_group" "groups" {
  for_each = local.root_enabled ? toset([for k, v in var.groups_users : k]) : []
  name     = title(each.key)
}

resource "aws_iam_user" "users" {
  for_each = local.root_enabled ? { for i in local.groups_users_list : i.user => i } : {}
  name     = each.value.user
}

resource "aws_iam_policy" "user_manage_own_creds" {
  for_each = local.root_enabled ? { for i in local.groups_users_list : i.user => i } : {}
  name        = "AllowManageOwnCreds-${each.value.user}"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowViewAccountInfo",
        "Effect": "Allow",
        "Action": [
          "iam:GetAccountPasswordPolicy",
          "iam:GetAccountSummary"
        ],
        "Resource": "*"
      },
      {
        "Sid": "AllowManageOwnPasswords",
        "Effect": "Allow",
        "Action": [
          "iam:ChangePassword",
          "iam:GetUser"
        ],
        "Resource": "arn:aws:iam::*:user/${each.value.user}"
      },
      {
        "Sid": "AllowManageOwnAccessKeys",
        "Effect": "Allow",
        "Action": [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey"
        ],
        "Resource": "arn:aws:iam::*:user/${each.value.user}"
      },
      {
        "Sid": "AllowManageOwnSSHPublicKeys",
        "Effect": "Allow",
        "Action": [
          "iam:DeleteSSHPublicKey",
          "iam:GetSSHPublicKey",
          "iam:ListSSHPublicKeys",
          "iam:UpdateSSHPublicKey",
          "iam:UploadSSHPublicKey"
        ],
        "Resource": "arn:aws:iam::*:user/${each.value.user}"
      }
    ]
  })
}

resource "aws_iam_user_group_membership" "groups_users" {
  for_each = local.root_enabled ? { for i in local.groups_users_list : i.user => i } : {}
  user     = each.value.user
  groups   = [each.value.group]
}

resource "aws_iam_policy" "child_account_access_policy" {
  for_each = local.root_enabled ? { for k, v in var.account_name_to_account_id : k => v if k != "root" } : {}
  name     = "GrantAccessToOrganizationAccountAccessRoleInYurtah${title(each.key)}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sts:AssumeRole"]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${each.value}:role/OrganizationAccountAccessRole"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "child_account_access_policy_to_admins" {
  for_each   = local.root_enabled ? { for k, v in var.account_name_to_account_id : k => v if k != "root" } : {}
  group      = "Admins"
  policy_arn = "arn:aws:iam::119831432021:policy/GrantAccessToOrganizationAccountAccessRoleInYurtah${title(each.key)}"
}