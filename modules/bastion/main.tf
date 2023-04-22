resource "aws_security_group" "this" {
  description = "Enable SSH access to the bastion host from external via SSH port"
  name        = var.name
  vpc_id      = var.vpc_id

  tags = local.tags

  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

resource "aws_security_group_rule" "ingress" {
  type             = "ingress"
  from_port        = "22"
  to_port          = "22"
  protocol         = "TCP"
  cidr_blocks      = concat(["75.70.7.210/32"], var.proofpoint_corp_ips)

  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type             = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.this.id
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  tags = local.tags

  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.name
  port        = "22"
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    port     = "traffic-port"
    protocol = "TCP"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "22"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}

resource "aws_launch_template" "this" {
  name                   = var.name
  image_id               = local.instance_configs[var.namespace]["image_id"]
  instance_type          = local.instance_configs[var.namespace]["instance_type"]
  vpc_security_group_ids    = [aws_security_group.this.id]
  update_default_version = true
  key_name               = local.key_name

  monitoring {
    enabled = true
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes = [tags.created_by]
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix = var.name

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
  max_size         = local.instance_configs[var.namespace]["asg_max_size"]
  min_size         = local.instance_configs[var.namespace]["asg_min_size"]
  desired_capacity = local.instance_configs[var.namespace]["asg_desired_capacity"]

  vpc_zone_identifier = var.public_subnet_ids

  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"

  target_group_arns = [
    aws_lb_target_group.this.arn
  ]

  termination_policies = [
    "OldestInstance"
  ]

  instance_refresh {
    strategy = "Rolling"
  }
}

resource "aws_route53_record" "this" {
  zone_id = var.main_zone_id
  name    = "bastion"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}