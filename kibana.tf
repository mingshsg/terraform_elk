module "kibana_instances" {
  source = "./modules/kibana"
  for_each = { for host in local.expanded_kibana_hosts : host.hostname => host }

  ami_id             = var.ami_id
  instance_type      = each.value.instance_type
  availability_zone  = each.value.availability_zone
  hostname           = each.value.hostname
  os_ebs_size_gb     = each.value.os_ebs_size_gb
  elasticsearch_nodes    = local.all_nodes
  subnet_id          = local.subnet_map[each.value.availability_zone]
  key_name           = var.ec2_provision_key
  security_group_ids = var.security_group_ids
  install_package    = var.kibana_package
  kibana_password    = var.kibana_pwd
  dns_zone_id        = aws_route53_zone.localdomain.zone_id
  ca_cert            = data.local_file.ca_cert.content
  server_cert        = data.local_file.server_cert.content
  server_key         = data.local_file.server_key.content
  tags               = merge(local.tags,{
      # additional tags
  })
}
