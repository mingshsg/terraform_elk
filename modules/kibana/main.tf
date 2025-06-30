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
    elasticsearch_nodes = join(",", local.elasticsearch_nodes)
    install_package = var.install_package
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
}

resource "aws_route53_record" "registry" {
  zone_id = var.dns_zone_id
  name    = "${var.hostname}.${local.domainname}"
  type    = "A"
  ttl     = 3600
  records = [aws_instance.this.private_ip]
}

locals {
  elasticsearch_nodes = [for item in var.elasticsearch_nodes : "https://${item}.${local.domainname}:9200"]
}

data "aws_route53_zone" "privatezone" {
  zone_id = var.dns_zone_id
}

locals {
  domainname = data.aws_route53_zone.privatezone.name
}