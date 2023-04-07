//locals {
//  enabled = contains([""], var.namespace) ? 1 : 0
//  eks_cluster_config = var.eks_cluster_config[var.namespace]
//}
//
//variable "namespace" {}
//
//variable "region" {
//  description = "Region in which the bastion host will be launched"
//}
//
//variable "vpc_id" {}
//
//variable "eks_cluster_config" {
//  type = map
//  default = {
//    lab = {
//      eks_version = "1.21"
//    }
//    prod = {
//      eks_version = "1.21"
//    }
//  }
//}
//
