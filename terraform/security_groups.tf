resource "aws_security_group" "vpn_sg" {
  name        = "vpn-sg"
  description = "Allow traffic for Client VPN"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  name_prefix = "lb_sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LB Security Group"
  }
}
# Security Group for App Server
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Security group for app server (application layer)"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow all traffic through HTTPS from Load Balancer"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidr_blocks
  }

  ingress {
    description = "Allow all traffic through HTTP from Load Balancer"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = var.public_subnet_cidr_blocks
  }

  ingress {
    description = "Allow SSH from EC2 agent"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_agent_cidr_blocks[0]]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "app_sg"
  }
}

# Security Group for Agent Server
resource "aws_security_group" "agent_sg" {
  name        = "agent_sg"
  description = "Security group agents servers"
  vpc_id      = aws_vpc.vpc.id


  ingress {
    description = "Allow SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "agent_sg"
  }
}


# Security Group for DB server
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description     = "Allow traffic only from the application sg"
    from_port       = "1433"
    to_port         = "1433"
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id, aws_security_group.agent_sg.id]
  }
  egress {
    description = "Allow outbound traffic for port 1433 for Agents and App servers"
    from_port   = "1433"
    to_port     = "1433"
    protocol    = "tcp"
    cidr_blocks = flatten([var.private_subnet_agent_cidr_blocks, var.private_subnet_app_cidr_blocks])
  }
  tags = {
    Name = "db_sg"
  }
}