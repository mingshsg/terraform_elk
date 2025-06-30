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

variable "os_ebs_size_gb" {
  type = number
}

variable "elasticsearch_nodes" {
  type = list(string)
}

variable "dns_zone_id" {
  type = string
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