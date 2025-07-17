#!/bin/bash
echo "${hostname}" > /etc/hostname
hostnamectl set-hostname ${hostname}

curl -o elasticsearch.rpm ${install_package}
# wget ${install_package} -O elasticsearch.rpm

dnf install ./elasticsearch.rpm -y

systemctl enable elasticsearch

#sed -i '/^cluster\.initial_master_nodes/s/^/#/' /etc/elasticsearch/elasticsearch.yml

mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.origin

mkdir /etc/elasticsearch/certs/ -p

echo '${server_cert}' >> /etc/elasticsearch/certs/server.pem
echo '${server_key}' >> /etc/elasticsearch/certs/server.decrypt.key
echo '${ca_cert}' >> /etc/elasticsearch/certs/ca.pem

cat <<EOF >> /etc/elasticsearch/elasticsearch.yml
node.name: ${hostname}
cluster.name: ${clustername}
network.bind_host: 0.0.0.0
transport.bind_host: 0.0.0.0
transport.publish_host: 0.0.0.0
discovery.seed_hosts: [ ${seed_nodes} ]
cluster.initial_master_nodes: [ ${master_nodes} ]
node.roles: [ ${roles} ]
bootstrap.memory_lock: true
xpack:
  security:
    enabled: true
    transport:
      ssl:
        enabled: true
        verification_mode: none
        certificate: /etc/elasticsearch/certs/server.pem
        key: /etc/elasticsearch/certs/server.decrypt.key
        certificate_authorities: ["/etc/elasticsearch/certs/ca.pem"]
    http:
      ssl:
        enabled: true
        verification_mode: none
        certificate: /etc/elasticsearch/certs/server.pem
        key: /etc/elasticsearch/certs/server.decrypt.key
        certificate_authorities: ["/etc/elasticsearch/certs/ca.pem"]

EOF

%{ if mount_data_disk ~}
mkfs -t xfs /dev/xvdf
mkdir -p /usr/share/elasticsearch/data
mount /dev/xvdf /usr/share/elasticsearch/data
echo "/dev/xvdf /usr/share/elasticsearch/data xfs defaults,nofail 0 2" >> /etc/fstab
%{ endif ~}

setfacl -Rm d:u:elasticsearch:rwX,u:elasticsearch:rwX /etc/elasticsearch/
setfacl -Rm d:u:elasticsearch:rwX,u:elasticsearch:rwX /usr/share/elasticsearch/

systemctl start elasticsearch

sleep 10
ELASTIC_PWD=$(sudo -u elasticsearch /usr/share/elasticsearch/bin/elasticsearch-reset-password -s -u elastic -b)
curl -X POST -sSL -k -v "https://localhost:9200/_security/user/kibana_system/_password?pretty" -H 'Content-Type: application/json' -d'{"password" : "${kibana_password}"}' -u elastic:$ELASTIC_PWD
curl -X POST -sSL -k -v "https://localhost:9200/_security/user/elastic/_password?pretty" -H 'Content-Type: application/json' -d'{"password" : "${elastic_password}"}' -u elastic:$ELASTIC_PWD
