#output "vpc_id" {
#  count = local.enabled
#  value = aws_vpc.vpc[0].id
#}
#
#output "public_subnets_id" {
#  count = local.enabled
#  value = ["${aws_subnet.public_subnet.*.id}"]
#}
#
#output "private_subnets_id" {
#  count = local.enabled
#  value = ["${aws_subnet.private_subnet.*.id}"]
#}
#
#output "default_sg_id" {
#  count = local.enabled
#  value = aws_security_group.default[0].id
#}
#
#output "security_groups_ids" {
#  count = local.enabled
#  value = ["${aws_security_group.default[0].id}"]
#}
#
#output "public_route_table" {
#  count = local.enabled
#  value = aws_route_table.public[0].id
#}