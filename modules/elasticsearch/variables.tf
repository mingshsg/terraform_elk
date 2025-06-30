variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "install_package" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "hostname" {
  type = string
}

variable "clustername" {
  type = string
  default = "awselasticsearchcluster"
}

variable "os_ebs_size_gb" {
  type = number
}

variable "data_ebs_size_gb" {
  type = number
}

variable "seed_nodes" {
  type = list(string)
}

variable "master_nodes" {
  type = list(string)
}

variable "dns_zone_id" {
  type = string
}

variable "roles" {
  type = list(string)
}

# Networking
variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
  default = {
  }
}

variable "elastic_password" {
  type = string
}

variable "kibana_password" {
  type = string
}

variable "ca_cert" {
  type = string
}

variable "server_cert" {
  type = string
}

variable "server_key" {
  type = string
}