# Replication Instance
resource "aws_dms_replication_instance" "dms_instance" {
  replication_instance_class = "dms.t3.micro" 
  allocated_storage          = 100 #
  replication_instance_id    = "dms-instance"
  publicly_accessible        = false
  apply_immediately          = true

  tags = {
    Name = "DMSReplicationInstance"
  }
  depends_on = [aws_db_instance.database]
}

# Source Endpoint (Azure SQL Database)
resource "aws_dms_endpoint" "source_endpoint" {
  endpoint_id   = "source-endpoint"
  endpoint_type = "source"
  engine_name   = "sqlserver" 

  database_name     = "source_database"  
  username          = var.remote_db_username
  password          = var.remote_db_password    
  server_name       = var.remote_db_endpoint   
  port              = var.remote_db_port        
  ssl_mode          = "none"          
}

# Target Endpoint
resource "aws_dms_endpoint" "target_endpoint" {
  endpoint_id   = "target-endpoint"
  endpoint_type = "target"
  engine_name   = "sqlserver" 

  database_name     = "target_database" 
  username          = var.db_username   
  password          = var.db_password    
  server_name       = aws_db_instance.database.endpoint
  port              = aws_db_instance.database.port
}

# DMS Task (Optional for Data Replication)
resource "aws_dms_replication_task" "dms_task" {
  replication_task_id          = "sql-dms-task"
  source_endpoint_arn          = aws_dms_endpoint.source_endpoint.endpoint_arn
  target_endpoint_arn          = aws_dms_endpoint.target_endpoint.endpoint_arn
  migration_type               = "full-load-and-cdc" 
  replication_instance_arn     = aws_dms_replication_instance.dms_instance.replication_instance_arn
  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
}