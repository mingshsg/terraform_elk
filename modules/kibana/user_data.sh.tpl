#!/bin/bash
echo "${hostname}" > /etc/hostname
hostnamectl set-hostname ${hostname}

wget ${install_package} -O kibana.rpm
dnf install ./kibana.rpm -y

systemctl enable kibana

mv /etc/kibana/kibana.yml /etc/kibana/kibana.yml.origin

mkdir /etc/kibana/certs/ -p

echo '${server_cert}' >> /etc/kibana/certs/server.pem
echo '${server_key}' >> /etc/kibana/certs/server.decrypt.key
echo '${ca_cert}' >> /etc/kibana/certs/ca.pem

cat <<EOF >> /etc/kibana/kibana.yml
server:
  name: kibana
  host: 0.0.0.0
  ssl:
    enabled: true
    certificate: "/etc/kibana/certs/server.pem"
    key: "/etc/kibana/certs/server.decrypt.key"
elasticsearch:
  hosts: [ ${elasticsearch_nodes} ]
  username: kibana_system
  password: ${kibana_password}
  ssl:
    certificateAuthorities: [ "/etc/kibana/certs/ca.pem" ]
    verificationMode: none
xpack:
  encryptedSavedObjects:
    encryptionKey: 4f8c3b9a8e7d4c5f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f
  reporting:
    roles:
      enabled: false

EOF

setfacl -Rm d:u:kibana:rwX,u:kibana:rwX /etc/kibana/
setfacl -Rm d:u:kibana:rwX,u:kibana:rwX /usr/share/kibana/

sleep 60 

systemctl start kibana
