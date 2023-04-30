variable "az_to_subnets" {}

variable "name" {}

variable "namespace" {}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}
variable "common_tags" {
  type = map(string)
}
