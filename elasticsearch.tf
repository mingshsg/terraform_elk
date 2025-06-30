module "es_instances" {
  source = "./modules/elasticsearch"
  for_each = { for host in local.expanded_es_hosts : host.hostname => host }

  ami_id             = var.ami_id
  instance_type      = each.value.instance_type
  availability_zone  = each.value.availability_zone
  hostname           = each.value.hostname
  os_ebs_size_gb     = each.value.os_ebs_size_gb
  data_ebs_size_gb   = each.value.data_ebs_size_gb
  seed_nodes         = each.value.seed_nodes
  master_nodes       = each.value.master_nodes
  roles              = each.value.roles
  subnet_id          = local.subnet_map[each.value.availability_zone]
  key_name           = var.ec2_provision_key
  security_group_ids = var.security_group_ids
  install_package    = var.elasticsearch_package
  elastic_password   = var.elastic_pwd
  kibana_password    = var.kibana_pwd
  dns_zone_id        = aws_route53_zone.localdomain.zone_id
  ca_cert            = data.local_file.ca_cert.content
  server_cert        = data.local_file.server_cert.content
  server_key         = data.local_file.server_key.content
  tags               = merge(local.tags,{
      # additional tags

  })
}

