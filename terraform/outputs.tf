# output "agent_public_ip" {
#   description = "The public IP address of the agent server"
#   value       = aws_eip.agent_eip[0].public_ip
#   depends_on = [aws_eip.agent_eip]
# }

# output "agent_public_dns" {
#   description = "The public DNS address of the agent server"
#   value       = aws_eip.agent_eip[0].public_dns

#   depends_on = [aws_eip.agent_eip]
# }

output "database_endpoint" {
  description = "The endpoint of the local database"
  value       = aws_db_instance.database.address
}

output "database_port" {
  description = "The port of the local database"
  value       = aws_db_instance.database.port
}

# Output the Load Balancer DNS
output "load_balancer_dns" {
  description = "The public DNS address of the Load Balancer"
  value = aws_lb.app_lb.dns_name
}

output "client_vpn_endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.client_vpn.id
}

output "vpn_gateway_id" {
  value = aws_vpn_gateway.vpn_gateway.id
}

output "key_pair_name_agent" {
  value = aws_key_pair.ec2_agent_kp.key_name
}

output "key_pair_fingerprint_agent" {
  value = aws_key_pair.ec2_agent_kp.fingerprint
}


output "key_pair_name_app" {
  value = aws_key_pair.ec2_app_kp.key_name
}

output "key_pair_fingerprint_app" {
  value = aws_key_pair.ec2_app_kp.fingerprint
}
