# Create the VPN Gateway
resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id          = aws_vpc.vpc.id
  amazon_side_asn = 65000  
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  client_cidr_block      = var.client_vpn_cidr_block
  server_certificate_arn = aws_acm_certificate.server_cert.arn

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_cert.arn 
  }

  connection_log_options {
    enabled = true
    cloudwatch_log_group = aws_cloudwatch_log_group.client_vpn_log_group.name  
  }

  description = "My Client VPN Endpoint"
}

resource "aws_cloudwatch_log_group" "client_vpn_log_group" {
  name = "/aws/vpn/client-vpn-logs"
}

resource "aws_ec2_client_vpn_network_association" "vpn_association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id             = aws_subnet.agent_subnet[0].id  
}

# Add Authorization Rule to the VPN Endpoint
resource "aws_ec2_client_vpn_authorization_rule" "vpn_authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr   = aws_vpc.vpc.cidr_block 
  authorize_all_groups   = true
}