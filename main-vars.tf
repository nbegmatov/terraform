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
  default     = ""
}

locals {
  enabled = contains(["root", "lab", "prod"], var.namespace) == true ? 1 : 0
  default_tags = {
    created_by = "${var.created_by}"
  }
}

