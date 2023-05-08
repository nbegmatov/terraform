# EKS Cluster
resource "aws_eks_cluster" "this" {
  name = "${var.name}-cluster"

  # reference for log_types:
  # https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  enabled_cluster_log_types = ["api", "audit"]

  role_arn = aws_iam_role.control_plane.arn

  # reference for EKS versions:
  # https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
  version = "1.23"

  vpc_config {
    # Security Groups considerations reference:
    # https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
    security_group_ids      = [aws_security_group.control_plane.id, aws_security_group.worker_nodes.id]
    subnet_ids              = var.public_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

# EKS Cluster IAM Role
resource "aws_iam_role" "control_plane" {
  name = "${var.name}-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.control_plane.name
}

# EKS Cluster Security Group
resource "aws_security_group" "control_plane" {
  name        = "${var.name}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.worker_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.control_plane.id
  source_security_group_id = aws_security_group.worker_nodes.id
  to_port                  = 65535
  type                     = "egress"
}

