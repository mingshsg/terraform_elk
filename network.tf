variable "vpc_id" {
  type = string
  default = "vpc-<id>"
}

locals {
  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]
}


variable "security_group_ids" {
  type = list(string)
  default = ["sg-<id>"]
}

locals {
  subnet_map = {
    "ap-southeast-1a" = "subnet-<ida>"
    "ap-southeast-1b" = "subnet-<idb>"
    "ap-southeast-1c" = "subnet-<idc>"
  }
}

resource "aws_route53_zone" "localdomain" {
  name = var.domainname

  vpc {
    vpc_id = var.vpc_id
  }

}

#data "aws_subnets" "selected" {
#  filter {
#    name   = "vpc-id"
#    values = [var.vpc_id]
#  }
#}

#data "aws_subnet" "all" {
#  for_each = toset(data.aws_subnets.selected.ids)
#
#  id = each.key
#
#}

#
#locals {
#  subnet_map = {
#    for az in local.availability_zones : az =>
#    # Get the first public subnet (sorted by subnet ID to ensure deterministic)
#    try(
#     sort([
#        for s in data.aws_subnet.all :
#        s.id if s.value.availability_zone == az && s.value.map_public_ip_on_launch
#      ])[0],
#      null
#    )
#  }
#}
