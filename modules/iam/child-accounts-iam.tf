data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_name_to_account_id["root"]}:root"]
    }
  }
}

resource "aws_iam_role" "assume_role" {
  for_each           = contains(["lab", "prod"], var.namespace) ? var.role_to_policy["${var.namespace}"] : {}
  name               = "${var.namespace}-${each.key}-access-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = {}
}

resource "aws_iam_role_policy_attachment" "assume_role_policy" {
  for_each   = contains(["lab", "prod"], var.namespace) ? { for policy_role in local.role_to_policy : "${policy_role.role}.${policy_role.policy}" => policy_role } : {}
  role       = aws_iam_role.assume_role[each.value.role].name
  policy_arn = "arn:aws:iam::aws:policy/${each.value.policy}"
}

