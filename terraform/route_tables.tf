resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = 	aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table" "agent_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "agent" {
  count          = var.subnet_count.agent
  route_table_id = aws_route_table.agent_rt.id
  subnet_id      = 	aws_subnet.agent_subnet[count.index].id
}


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "private_rt_db" {
  vpc_id = aws_vpc.vpc.id
}


resource "aws_route_table_association" "private_app" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_app_subnet[count.index].id
}

resource "aws_route_table_association" "private_db" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.private_rt_db.id
  subnet_id      = aws_subnet.private_db_subnet[count.index].id
}

resource "aws_route" "vpn_route" {
  route_table_id         = aws_vpc.vpc.default_route_table_id 
  destination_cidr_block = "10.10.0.0/22" 
  gateway_id             = aws_vpn_gateway.vpn_gateway.id 
}


