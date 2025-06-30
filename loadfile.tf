data "local_file" "server_cert" {
  filename = "files/server.pem"
}

data "local_file" "server_key" {
  filename = "files/server.decrypt.key"
}

data "local_file" "ca_cert" {
  filename = "files/ca.pem"
}

# currently listing dummy certificates
