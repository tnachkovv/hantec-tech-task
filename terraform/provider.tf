terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "rhel_9-3" {
  most_recent = "true"
//  id = "ami-023c11a32b0207432"

  filter {
    name   = "name"
    values = ["RHEL-9.3.0_HVM-20231101-x86_64-5-Hourly2-GP2"]
  }
  owners = ["309956199498"]
}