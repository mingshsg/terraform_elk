# Terraform ELK Stack Deployment

This repository contains Terraform configuration for deploying a production-ready ELK (Elasticsearch, Logstash, Kibana) stack on AWS. The infrastructure is designed to be scalable, highly available, and secure with SSL/TLS encryption.

## Project Description

This Terraform project automates the deployment of an Elasticsearch cluster with Kibana instances on AWS EC2. The configuration supports:

- **Multi-node Elasticsearch cluster** with configurable roles (master, data, ingest, ML)
- **Data tier architecture** supporting hot, cold, and frozen tiers
- **Kibana instances** for visualization and management
- **High availability** across multiple AWS availability zones
- **SSL/TLS encryption** for secure communication
- **Private DNS** using Route53 private hosted zones
- **Modular architecture** for easy customization and maintenance

## Requirements

### Software Prerequisites

- **Terraform**: Version 1.0 or higher
- **AWS CLI**: Configured with appropriate credentials
- **AWS Account**: With sufficient permissions to create EC2, VPC, Route53, and IAM resources

### AWS Resources

Before deploying, you need:

1. **VPC**: An existing VPC with proper network configuration
2. **Subnets**: At least 3 subnets across different availability zones
3. **Security Groups**: Configured to allow necessary traffic between ELK components
4. **EC2 Key Pair**: For SSH access to instances
5. **SSL/TLS Certificates**: CA certificate, server certificate, and private key (placed in the `files/` directory)

### Required Files

Place the following certificate files in the `files/` directory:

- `ca.pem` - Certificate Authority certificate
- `server.pem` - Server certificate
- `server.decrypt.key` - Decrypted private key

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/mingshsg/terraform_elk.git
cd terraform_elk
```

### 2. Configure Variables

Edit the `variables.tf` and `network.tf` files to match your AWS environment:

**Key variables to update:**

- `aws_region` - Your target AWS region (default: `ap-southeast-1`)
- `vpc_id` - Your existing VPC ID
- `security_group_ids` - Your security group IDs
- `subnet_map` - Map of availability zones to subnet IDs
- `ec2_provision_key` - Your EC2 key pair name
- `elastic_pwd` - Elasticsearch superuser password
- `kibana_pwd` - Kibana system user password

**Example network.tf configuration:**

```hcl
variable "vpc_id" {
  type    = string
  default = "vpc-xxxxxxxxxxxxx"
}

variable "security_group_ids" {
  type    = list(string)
  default = ["sg-xxxxxxxxxxxxx"]
}

locals {
  subnet_map = {
    "ap-southeast-1a" = "subnet-xxxxxxxxxxxxx"
    "ap-southeast-1b" = "subnet-yyyyyyyyyyy"
    "ap-southeast-1c" = "subnet-zzzzzzzzzzz"
  }
}
```

### 3. Configure Server List

Modify `serverlist.tf` to define your Elasticsearch and Kibana nodes:

- Adjust the number of nodes per tier
- Configure instance types and EBS volumes
- Set node roles (master, data_hot, data_cold, ingest, ml, etc.)

### 4. Prepare SSL Certificates

Place your SSL/TLS certificates in the `files/` directory:

```bash
mkdir -p files
cp /path/to/ca.pem files/
cp /path/to/server.pem files/
cp /path/to/server.decrypt.key files/
```

### 5. Initialize Terraform

```bash
terraform init
```

This downloads the required providers and initializes the working directory.

### 6. Plan the Deployment

```bash
terraform plan
```

Review the execution plan to ensure all resources will be created as expected.

### 7. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment. This process will:

- Create EC2 instances for Elasticsearch and Kibana
- Configure EBS volumes for data storage
- Set up Route53 DNS records
- Install and configure Elasticsearch and Kibana
- Apply SSL/TLS certificates

The deployment typically takes 10-15 minutes to complete.

### 8. Verify the Deployment

After successful deployment, you can check the outputs:

```bash
terraform output
```

This will display:
- Master node hostnames
- All Elasticsearch nodes
- Ingest nodes
- Kibana instances

## Usage Example

### Basic Workflow

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply

# View outputs
terraform output

# Access Kibana (via SSH tunnel or VPN)
# Navigate to: https://<kibana-hostname>:5601

# Destroy infrastructure when done
terraform destroy
```

### Accessing the ELK Stack

Since the deployment uses private networking:

1. **SSH into a bastion host** or use AWS Systems Manager Session Manager
2. **Set up an SSH tunnel** to access Kibana:
   ```bash
   ssh -i your-key.pem -L 5601:kbn-01.elastictest.local:5601 ec2-user@<bastion-ip>
   ```
3. **Access Kibana** in your browser: `https://localhost:5601`
4. **Login** with username `elastic` and the password you configured

### Customizing the Deployment

**Add more Elasticsearch nodes:**

Edit `serverlist.tf` and add nodes to the appropriate tier:

```hcl
hosts = [
  {
    hostname = "es-hot-03",
    availability_zone = "${var.aws_region}c"
  }
]
```

**Change Elasticsearch/Kibana version:**

Update the package URLs in `variables.tf`:

```hcl
variable "elasticsearch_package" {
  type    = string
  default = "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-9.0.2-x86_64.rpm"
}
```

## Project Structure

```
.
├── elasticsearch.tf         # Elasticsearch module invocation
├── kibana.tf               # Kibana module invocation
├── network.tf              # Network configuration (VPC, subnets, Route53)
├── variables.tf            # Global variables and AWS provider config
├── serverlist.tf           # Node definitions and configurations
├── loadfile.tf             # Certificate file loading
├── outputs.tf              # Terraform outputs
├── files/                  # SSL/TLS certificates
│   ├── ca.pem
│   ├── server.pem
│   └── server.decrypt.key
└── modules/
    ├── elasticsearch/      # Elasticsearch module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── kibana/            # Kibana module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Architecture

The deployment creates:

- **Elasticsearch Cluster**: Multi-node cluster with configurable roles
  - Master nodes for cluster management
  - Data nodes (hot/cold/frozen tiers) for data storage
  - Ingest nodes for data processing
  - ML nodes for machine learning workloads
  
- **Kibana Instances**: Multiple instances for high availability

- **Networking**: Private DNS zone with Route53 for service discovery

- **Storage**: Separate EBS volumes for OS and data

## Security Considerations

- All communication is encrypted with SSL/TLS
- Passwords should be managed securely (consider using AWS Secrets Manager)
- Security groups should follow the principle of least privilege
- Consider using AWS Systems Manager instead of SSH keys for access
- Keep Elasticsearch and Kibana versions up to date with security patches

## Troubleshooting

### Common Issues

**Certificate errors:**
- Ensure certificate files are present in the `files/` directory
- Verify certificates are not expired
- Check that the private key is decrypted

**Connection failures:**
- Verify security group rules allow necessary ports
- Check that subnets have proper routing
- Ensure DNS resolution is working in the VPC

**Terraform errors:**
- Run `terraform validate` to check configuration syntax
- Verify AWS credentials are properly configured
- Check that all required variables are set

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Submit a pull request

Please ensure your code follows Terraform best practices and includes appropriate documentation.

## License

This project is provided as-is for educational and production use. Please review and comply with the licenses of the underlying components:

- [Elasticsearch](https://www.elastic.co/pricing/faq/licensing)
- [Kibana](https://www.elastic.co/pricing/faq/licensing)
- [Terraform](https://www.mozilla.org/en-US/MPL/2.0/)

## Contact Information

For questions, issues, or support:

- **Repository**: [https://github.com/mingshsg/terraform_elk](https://github.com/mingshsg/terraform_elk)
- **Issue Tracker**: [https://github.com/mingshsg/terraform_elk/issues](https://github.com/mingshsg/terraform_elk/issues)
- **Maintainer**: @mingshsg

## Acknowledgments

Built with:
- [Terraform](https://www.terraform.io/) - Infrastructure as Code
- [Elasticsearch](https://www.elastic.co/elasticsearch/) - Search and Analytics Engine
- [Kibana](https://www.elastic.co/kibana/) - Visualization Platform
- [AWS](https://aws.amazon.com/) - Cloud Infrastructure

---

**Note**: This is a production-grade infrastructure template. Always test in a non-production environment first and ensure you understand the costs associated with the AWS resources created by this configuration.
