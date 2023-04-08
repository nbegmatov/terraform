variable "name" {}

variable "namespace" {}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "CIDR block for Public Subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "CIDR block for Private Subnet"
}

variable "region" {
  description = "Region in which the bastion host will be launched"
}

variable "common_tags" {
  type = map(string)
}

locals {
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}