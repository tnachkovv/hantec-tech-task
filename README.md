# README for Terraform Scripts

## Overview
This repository contains Terraform scripts to deploy infrastructure in AWS for a database migration project. The following resources are provisioned:

- **Database Migration Service (DMS)**:
  - Replication instance, endpoints, and tasks.
- **RDS**:
  - Instance, option group, and connectivity settings.
- **Networking and IAM**:
  - VPC, subnets, route tables, security groups, and IAM roles.
- **Load Balancer**:
  - Configuration and listener setup.
- **EC2 Instances**:
  - Provisioning for application servers and agents.
- **VPN and Certificates**:
  - VPN gateway, SSL/TLS certificates, and key pairs.

## Prerequisites
1. **Terraform**: Ensure Terraform is installed (`terraform --version` to verify).
2. **AWS Credentials**: Export AWS access and secret keys as environment variables.
   ```bash
   export AWS_ACCESS_KEY_ID="<your_access_key>"
   export AWS_SECRET_ACCESS_KEY="<your_secret_key>"
   ```
3. **Certificates**: Generate required certificates using [Easy-RSA](https://github.com/OpenVPN/easy-rsa/releases).

## Usage
1. **Clone the Repository**:
   ```bash
   git clone <repository_url>
   cd <repository_directory>
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan Deployment**:
   ```bash
   terraform plan
   ```

4. **Apply Changes**:
   ```bash
   terraform apply
   ```

5. **Verify Deployment**:
   Use the AWS Management Console to verify the resources.

6. **Destroy Resources (Optional)**:
   ```bash
   terraform destroy
   ```

## Directory Structure
- **`vpc.tf`**: Defined the VPC configuration. 
- **`dms.tf`**: Configuration for Database Migration Service.
- **`instances.tf`**: Configuration for RDS SQL Server and EC2 instances. 
- **`lb.tf`**: Configuration for Load balancer
- **`variables.tf`**: Defines input variables.
- **`outputs.tf`**: Specifies outputs.
- **`provider.tf`**: Configures provider settings.
- **`vpn.tf`**: Contains VPN Point-to-Site Configuration (VPN Gateway and Client Endpoint)
- **`iam.tf`**: Contains RDS and DMS Roles. 
- **`certficiates.tf`**: Imports predefined certificates used for mutual vpn authentication
- **`nat.tf`**: Defined NAT Gateway.
- **`route-tables.tf`**: Defines route table within the VPC. 
- **`security-groups.tf`**:  Defines the security groups within the VPC. 
- **`subnets.tf`**:  Defines the subnets within the VPC.
- **`key-pairs.tf`**:  Defines key-pairs used for EC2 instances authentication. 

## Notes
- Customize the `variables.tf` file as per project requirements.
- Ensure to safeguard sensitive data, such as AWS credentials and certificate files.

For any issues or improvements, feel free to submit a pull request or contact the project maintainer.
