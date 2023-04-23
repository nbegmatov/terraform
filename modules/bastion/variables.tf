locals {
  key_name = "${var.namespace}-bh-key"
  tags = merge({
    Name = "${var.namespace}-${var.name}"
  }, var.common_tags)

  instance_configs = {
    "lab" = {
      image_id             = "ami-06878d265978313ca"
      instance_type        = "t2.micro"
      key_name             = ""
      asg_max_size         = 1
      asg_min_size         = 1
      asg_desired_capacity = 1
    }
  }
}

variable "proofpoint_corp_ips" {
  type = list(string)

  default = [
    "71.42.188.224/29",   # Austin, TX, USA
    "119.63.221.0/29",    # Australia
    "115.146.64.208/29",  # Australia
    "199.33.143.128/25",  # Denver, CO, USA
    "89.185.154.176/28",  # Belfast, Northern Ireland, UK
    "148.252.15.42/32",   # Belfast, Northern Ireland, UK
    "50.233.255.178/32",  # Broomfield, CO, USA
    "198.60.24.128/27",   # Draper, UT, USA
    "50.207.17.226/32",   # Indianapolis, IN, USA
    "31.168.38.44/32",    # Israel
    "64.79.137.168/29",   # Las Vegas, NV, USA
    "208.103.114.184/29", # Pittsburg, PA, USA
    "50.243.174.184/30",  # Pittsburg, PA, USA
    "80.252.75.162/32",   # Reading, UK
    "63.237.219.41/32",   # SC4 Lab
    "208.86.202.8/30",    # Sunnyvale, CA, USA
    "115.146.66.46/32",   # Sydney, NS, Canada
    "199.203.189.58/32",  # Tel Aviv, Israel
    "84.110.129.122/32",  # Tel Aviv, Israel
    "62.90.78.154/32",    # Tel Aviv, Israel
    "118.238.251.64/26",  # Tokyo, Japan
    "76.9.192.136/29",    # Toronto, ON, Canada
    "66.46.237.178/32",   # Toronto, ON, Canada
  ]
}

variable "name" {}
variable "vpc_id" {}
variable "namespace" {}
variable "common_tags" {}
variable "public_subnet_ids" {}
variable "main_zone_id" {}
