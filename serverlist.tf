locals{
 es_nodes = [
  {
    roles           = ["data_hot", "ingest", "transform", "data_content","remote_cluster_client", "master"]
    instance_type   = "t3a.medium"
    os_ebs_size_gb  = 8
    data_ebs_size_gb = 10
    hosts       = [
      {
        hostname = "es-hot-01",
        availability_zone = "${var.aws_region}a"
      },
      {
        hostname = "es-hot-02",
        availability_zone = "${var.aws_region}b"
      }
    ]
  },
  #{
  #  roles           = ["data_cold","remote_cluster_client"]
  #  instance_type   = "t3a.medium"
  #  os_ebs_size_gb  = 8
  #  data_ebs_size_gb = 5
 #   hosts      = [
  #    {
  #      hostname = "es-cold-01",
  #      availability_zone = "${var.aws_region}c"
   #   },
   #   {
   #     hostname = "es-cold-02",
   #     availability_zone = "${var.aws_region}a"
   #   }
  #  ]
  #},
  #{
  #  roles           = ["data_frozen","remote_cluster_client"]
  #  instance_type   = "t3a.medium"
  #  os_ebs_size_gb  = 8
  #  data_ebs_size_gb = 5
  #  hosts       = [
  #    {
  #      hostname = "es-frozen-01",
  #      availability_zone = "${var.aws_region}b"
  #    },
   #   {
  #      hostname = "es-frozen-02",
  #      availability_zone = "${var.aws_region}c"
   #   }
  #  ]
  #},
  {
    roles           = ["master","remote_cluster_client"]
    instance_type   = "t3a.medium"
    os_ebs_size_gb  = 8
    data_ebs_size_gb = 0
    hosts       = [
      {
        hostname = "es-master-01",
        availability_zone = "${var.aws_region}a"
      }
    ]
  },
  {
    roles           = ["ml","remote_cluster_client"]
    instance_type   = "t3a.medium"
    os_ebs_size_gb  = 8
    data_ebs_size_gb = 0
    hosts       = [
      {
        hostname = "es-ml-01",
        availability_zone = "${var.aws_region}b"
      }
    ]
  }
]
}

locals {
  kibana_nodes={
    instance_type   = "t3a.medium"
    os_ebs_size_gb  = 8
    hosts       = [
      {
        hostname = "kbn-01",
        availability_zone = "${var.aws_region}c"
      },
      {
        hostname = "kbn-02",
        availability_zone = "${var.aws_region}a"
      }
    ]
  }
}

# ======================================== #
# below uses to expand the data from above #
# ======================================== #

locals {
  all_nodes = flatten([
    for group in local.es_nodes : [
      for host in group.hosts : host.hostname
    ]
  ])
}

locals {
  master_nodes = flatten([
    for group in local.es_nodes : [
      for host in group.hosts : host.hostname
      if contains(group.roles, "master")
    ]
  ])
}

locals {
  ingest_nodes = flatten([
    for group in local.es_nodes : [
      for host in group.hosts : host.hostname
      if contains(group.roles, "ingest")
    ]
  ])
}

locals {
  # Flattened and enriched host list with master_nodes excluding itself
  expanded_es_hosts = flatten([
    for group in local.es_nodes : [
      for host in group.hosts : {
        hostname          = host.hostname
        availability_zone = host.availability_zone
        roles             = group.roles
        instance_type     = group.instance_type
        os_ebs_size_gb    = group.os_ebs_size_gb
        data_ebs_size_gb  = group.data_ebs_size_gb
        seed_nodes        = [for m in local.master_nodes : m if m != host.hostname]
        master_nodes      = [for m in local.master_nodes : m]
      }
    ]
  ])
}

locals {
  expanded_kibana_hosts = [
    for host in local.kibana_nodes.hosts : {
      hostname          = host.hostname
      availability_zone = host.availability_zone
      instance_type     = local.kibana_nodes.instance_type
      os_ebs_size_gb    = local.kibana_nodes.os_ebs_size_gb
    }
  ]
}