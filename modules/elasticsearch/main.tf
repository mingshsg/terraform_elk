resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids

  tags = merge({
    Name = var.hostname
  }, var.tags)

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    hostname        = "${var.hostname}.${local.domainname}"
    clustername     = var.clustername
    seed_nodes      = join(",", local.seed_nodes)
    master_nodes    = join(",", local.master_nodes)
    roles           = join(",", var.roles)
    install_package = var.install_package
    mount_data_disk = var.data_ebs_size_gb > 0 ? true : false
    elastic_password = var.elastic_password
    kibana_password = var.kibana_password
    ca_cert         = var.ca_cert
    server_cert     = var.server_cert
    server_key      = var.server_key
  })

  root_block_device {
    volume_size = var.os_ebs_size_gb
    volume_type = "gp3"
    tags = var.tags
  }

  dynamic "ebs_block_device" {
    for_each = var.data_ebs_size_gb > 0 ? [1] : []
    content {
      device_name = "/dev/xvdf"
      volume_size = var.data_ebs_size_gb
      volume_type = "gp3"
      tags = var.tags
    }
  }
}

resource "aws_route53_record" "registry" {
  zone_id = var.dns_zone_id
  name    = "${var.hostname}.${local.domainname}"
  type    = "A"
  ttl     = 3600
  records = [aws_instance.this.private_ip]
}


locals {
  seed_nodes = [for item in var.seed_nodes : "${item}.${local.domainname}"]
}

locals {
  master_nodes = [for item in var.master_nodes : "${item}.${local.domainname}"]
}

data "aws_route53_zone" "privatezone" {
  zone_id = var.dns_zone_id
}

locals {
  domainname = data.aws_route53_zone.privatezone.name
}