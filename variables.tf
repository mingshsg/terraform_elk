provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type = string
  default = "ap-southeast-1" # sydney 2 singapore 1 Malysia 5 # need to change the subnet mapping and vpc in network.tf as well if to change
}

variable "instance_type" {
  type = string
  default = "t3a.medium" # did not used variable
}

variable "ami_id" {
  type = string
  default = "ami-0435fcf800fb5418d"
  # AWS Linux 2023 kernel-6.1 on 2025-06-27
}

variable "elasticsearch_package" {
  type = string
  default = "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-9.0.2-x86_64.rpm"
}

variable "kibana_package" {
  type = string
  default = "https://artifacts.elastic.co/downloads/kibana/kibana-9.0.2-x86_64.rpm"
}

variable "ec2_provision_key" {
  description = "ec2_keyname"
  type        = string
  default     = "mingshen-ec2-key"
}

variable "domainname" {
  description = "local domain name"
  type        = string
  default     = "elastictest.local"
}

#variable "target_version" {
#  type        = string
#  default     = "9.0.2"
#}

#variable "target_architecture" {
#  type        = string
#  default     = "x86_64"
#}

variable "elastic_pwd" {
  description = "elasticsearch password"
  type        = string
  default     = "elastic_password"
}

variable "kibana_pwd" {
  description = "kibana password"
  type        = string
  default     = "kibana_password"
}

# === below is for testing tags === #

locals {
  tags = {
    createdby = "terraform"
    purpose   = "test"
  }
}
