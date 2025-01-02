variable "aws_region" {
  default = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 2,
    private = 2
    agent = 1
  }
}

variable "client_vpn_cidr_block" {
  description = "CIDR block for VPN"
  type        = string
  default     = "10.10.0.0/22"
  }

variable "settings" {
  description = "Configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage     = 20
      max_allocated_storage = 20
      engine                = "sqlserver-ex"
      instance_class        = "db.t3.micro"
      db_name               = "sqlserver-db"
      rds_multi_az          = true
      engine_version        = "15.00"
      rds_multi_az          = false
      skip_final_snapshot   = true
      storage_type          = "gp2"
    },
    "app" = {
      count                   = 1
      instance_type           = "t2.micro"
      public_ip               = false
      map_public_ip_on_launch = false
    },
     "agent" = {
      count                   = 1
      instance_type           = "t2.small"
      public_ip               = false
      map_public_ip_on_launch = false
    }
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}

variable "private_subnet_web_cidr_blocks" {
  description = "Available CIDR blocks for private subnets for web layer"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
  ]
}

variable "private_subnet_app_cidr_blocks" {
  description = "Available CIDR blocks for private subnets for app layer"
  type        = list(string)
  default = [
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}

variable "private_subnet_db_cidr_blocks" {
  description = "Available CIDR blocks for private subnets for db layer"
  type        = list(string)
  default = [
    "10.0.105.0/24",
    "10.0.106.0/24",
  ]
}

variable "private_subnet_agent_cidr_blocks" {
  description = "Available CIDR blocks for private subnets for app layer"
  type        = list(string)
  default = [
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}

variable "db_username" {
  description = "Database master user"
  type        = string
  sensitive   = false
}

variable "db_password" {
  description = "Database master user password"
  type        = string
  sensitive   = true
}

variable "remote_db_username" {
  description = "Remote Database user for the source endpoint"
  sensitive   = false
}

variable "remote_db_password" {
  description = "Remote Database password for the source endpoint"
  sensitive   = true
}

variable "remote_db_endpoint" {
  description = "Database endpoint for the source endpoint"
  sensitive   = true
}

variable "remote_db_port" {
  description = "Database port for the source endpoint"
  default     = 1433 
}
