resource "aws_db_instance" "database" {
  identifier             = var.settings.database.db_name
  license_model          = "license-included"
  storage_type           = var.settings.database.storage_type
  engine                 = var.settings.database.engine
  engine_version         = var.settings.database.engine_version
  instance_class         = var.settings.database.instance_class
  allocated_storage      = var.settings.database.allocated_storage
  max_allocated_storage  = var.settings.database.max_allocated_storage 
  multi_az               = var.settings.database.rds_multi_az
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = var.settings.database.skip_final_snapshot
  option_group_name    = aws_db_option_group.rds_option_group.name
  
}

resource "aws_instance" "app" {
  count                  = var.settings.app.count
  ami                    = data.aws_ami.rhel_9-3.id
  instance_type          = var.settings.app.instance_type
  subnet_id              = aws_subnet.private_app_subnet[count.index].id
  key_name               = aws_key_pair.ec2_app_kp.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data = file("app_config.sh")
  associate_public_ip_address = var.settings.app.public_ip

  tags = {
    Name = "app-${count.index+1}"
  }
}

resource "aws_instance" "agent" {
  count                  = var.settings.agent.count
  ami                    = data.aws_ami.rhel_9-3.id
  instance_type          = var.settings.agent.instance_type
  subnet_id              = aws_subnet.agent_subnet[0].id
  key_name               = aws_key_pair.ec2_agent_kp.key_name
  vpc_security_group_ids = [aws_security_group.agent_sg.id]
  user_data = file("agent_config.sh")
  associate_public_ip_address = var.settings.agent.public_ip


  

  tags = {
    Name = "agent-${count.index+1}"
  }
}