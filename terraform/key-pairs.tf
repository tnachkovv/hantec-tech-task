
resource "aws_key_pair" "ec2_agent_kp" {
  key_name   = "ec2_agent_kp"
  public_key = tls_private_key.ec2_agent_kp.public_key_openssh
}

resource "aws_key_pair" "ec2_app_kp" {
  key_name   = "ec2_app_kp"
  public_key = tls_private_key.ec2_app_kp.public_key_openssh
}


resource "tls_private_key" "ec2_agent_kp" {
  algorithm = "RSA"
  rsa_bits  = 2048
}


resource "tls_private_key" "ec2_app_kp" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save private keys to local files
resource "local_file" "ec2_agent_key" {
  content  = tls_private_key.ec2_agent_kp.private_key_pem
  filename = "${path.module}/ec2_agent_kp.pem"
}

resource "local_file" "ec2_app_key" {
  content  = tls_private_key.ec2_app_kp.private_key_pem
  filename = "${path.module}/ec2_app_kp.pem"
}