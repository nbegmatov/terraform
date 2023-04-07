//# https://adamtheautomator.com/terraform-eks-module/
//
//# Creating IAM role for Kubernetes clusters to make calls to other AWS services on your behalf to manage the resources that you use with the service.
//
//resource "aws_iam_role" "iam-role-eks-cluster" {
//  count = local.enabled
//  name = "${var.namespace}-EKS-cluster-role"
//  assume_role_policy = <<POLICY
//{
// "Version": "2012-10-17",
// "Statement": [
//   {
//   "Effect": "Allow",
//   "Principal": {
//    "Service": "eks.amazonaws.com"
//   },
//   "Action": "sts:AssumeRole"
//   }
//  ]
// }
//POLICY
//}
//
//# Attaching the EKS-Cluster policies to the terraformekscluster role.
//
//resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
//  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
//  role       = "${aws_iam_role.iam-role-eks-cluster[0].name}"
//}
//
//resource "aws_security_group" "eks-cluster" {
//  count = local.enabled
//  name        = "${var.namespace}-EKS-cluster-SG"
//  vpc_id      = var.vpc_id
//
//  # Egress allows Outbound traffic from the EKS cluster to the  Internet
//
//  egress {                   # Outbound Rule
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//  # Ingress allows Inbound traffic to EKS cluster from the  Internet
//
//  ingress {                  # Inbound Rule
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//}
//
//# Creating the EKS cluster
//
//resource "aws_eks_cluster" "eks_cluster" {
//  name     = "${var.namespace}-EKS-cluster"
//  role_arn =  "${aws_iam_role.iam-role-eks-cluster.arn}"
//  version  = local.eks_cluster_config["eks_version"]
//
//  # Adding VPC Configuration
//
//  vpc_config {             # Configure EKS with vpc and network settings
//    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
//    subnet_ids         = ["subnet-1312586","subnet-8126352"]
//  }
//
//  depends_on = [
//    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy",
//    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
//  ]
//}
//#name  = "es-log-input-${local.es_cluster_properties["es_prefix"]}-${var.namespace}"
//
//# Creating IAM role for EKS nodes to work with other AWS Services.
//
//
//resource "aws_iam_role" "eks_nodes" {
//  name = "eks-node-group"
//
//  assume_role_policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow",
//      "Principal": {
//        "Service": "ec2.amazonaws.com"
//      },
//      "Action": "sts:AssumeRole"
//    }
//  ]
//}
//POLICY
//}
//
//# Attaching the different Policies to Node Members.
//
//resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
//  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
//  role       = aws_iam_role.eks_nodes.name
//}
//
//resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
//  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
//  role       = aws_iam_role.eks_nodes.name
//}
//
//resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
//  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
//  role       = aws_iam_role.eks_nodes.name
//}
//
//# Create EKS cluster node group
//
//resource "aws_eks_node_group" "node" {
//  cluster_name    = aws_eks_cluster.eks_cluster.name
//  node_group_name = "node_group1"
//  node_role_arn   = aws_iam_role.eks_nodes.arn
//  subnet_ids      = ["subnet-","subnet-"]
//
//  scaling_config {
//    desired_size = 1
//    max_size     = 1
//    min_size     = 1
//  }
//
//  depends_on = [
//    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
//    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
//    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
//  ]
//}