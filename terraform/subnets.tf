resource "aws_subnet" "public_subnet" {
  count             = var.subnet_count.public
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_subnet" "private_app_subnet" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_app_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.settings.app.map_public_ip_on_launch

  tags = {
    Name = "private_app_subnet_${count.index}"
  }
}

resource "aws_subnet" "private_db_subnet" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_db_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private_db_subnet_${count.index}"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db_subnet_group"
  description = "DB subnet group"
  subnet_ids  = [for subnet in aws_subnet.private_db_subnet : subnet.id]
}

resource "aws_subnet" "agent_subnet" {
  count             = var.subnet_count.agent
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_agent_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.settings.agent.map_public_ip_on_launch
  tags = {
    Name = "agent_subnet_${count.index}"
  }
}

