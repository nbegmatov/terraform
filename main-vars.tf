data "terraform_remote_state" "tf_state" {
  backend = "s3"

  config = {
    bucket = "${var.org}-${var.namespace}-tf-state-bucket"
    key    = "${var.namespace}-terraform-state"
    region = "us-east-1"
  }
}

locals {
  vpc_id = lookup(data.terraform_remote_state.tf_state.outputs, "vpc_id", "")
  enabled = contains(["root", "lab", "prod"], var.namespace) == true ? 1 : 0
  common_tags = {
    created_by = var.created_by
    Environment = var.namespace
  }
}

data "aws_route53_zone" "main_zone" {
  name         = var.main_zone_name
  private_zone = false
}

variable "main_zone_name" {
}

variable "org" {
  default = "yurtah"
}

variable "account" {
  default = "root"
}

variable "account_list" {
  default = ["root", "lab", "prod"]
}

variable "child_accounts" {
  default = ["lab", "prod"]
}

variable "account_name_to_account_id" {
  default = {
    root = "119831432021"
    lab  = "535741076684"
    prod = "249298271483"
  }
}

variable "region" {
  default = "us-east-1"
}

variable "namespace" {
  default = "root"
}

variable "namespace_list" {
  default = ["root", "lab", "staging", "prod"]
}

variable "namespace_to_account" {
  type = map(string)

  default = {
    lab     = "lab"
    staging = "prod"
    prod    = "prod"
  }
}

variable "created_by" {
  description = "User who is executing this script"
  default     = null
}
