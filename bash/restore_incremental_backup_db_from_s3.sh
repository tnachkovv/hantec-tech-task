#!/bin/bash

# Help section
function print_help {
  echo "Usage: $0 <DBUser> <DBPassword> <DBName> <DBInstanceEndpoint> <S3DiffBackupArn> <S3LogBackupArns>"
  echo "Description: Restores the differential backup and transaction logs to the database."
  echo "Arguments:"
  echo "  <DBUser>             : DB username"
  echo "  <DBPassword>         : DB password"
  echo "  <DBName>             : Database name"
  echo "  <DBInstanceEndpoint> : DB instance endpoint"
  echo "  <S3DiffBackupArn>    : ARN of the differential backup in S3"
  echo "  <S3LogBackupArns>    : Comma-separated ARNs of transaction log backups in S3"
  exit 1
}

# Check if help is requested or arguments are missing
if [ "$1" == "--help" ] || [ "$#" -ne 6 ]; then
  print_help
fi

# Set variables from arguments
DB_USER=$1
DB_PASSWORD=$2
DB_NAME=$3
DB_INSTANCE_ENDPOINT=$4
S3_DIFF_BACKUP_ARN=$5
S3_LOG_BACKUP_ARNS=$6

# Restore differential backup with NORECOVERY
echo "Restoring differential backup..."
sqlcmd -S "$DB_INSTANCE_ENDPOINT" -U "$DB_USER" -P "$DB_PASSWORD" -Q "
USE master;
EXEC msdb.dbo.rds_restore_database
  @restore_db_name='$DB_NAME',
  @s3_arn_to_restore_from='$S3_DIFF_BACKUP_ARN',
  @type='DIFFERENTIAL',
  @with_norecovery=1;
"
if [ $? -ne 0 ]; then
  echo "Error: Failed to restore differential backup."
  exit 1
fi

# Restore transaction logs
IFS=',' read -ra LOG_BACKUP_ARNS <<< "$S3_LOG_BACKUP_ARNS"
for LOG_BACKUP_ARN in "${LOG_BACKUP_ARNS[@]}"; do
  echo "Restoring transaction log from $LOG_BACKUP_ARN..."
  sqlcmd -S "$DB_INSTANCE_ENDPOINT" -U "$DB_USER" -P "$DB_PASSWORD" -C -Q "
  USE master;
  EXEC msdb.dbo.rds_restore_log
    @restore_db_name='$DB_NAME',
    @s3_arn_to_restore_from='$LOG_BACKUP_ARN',
    @with_norecovery=1;
  "
  if [ $? -ne 0 ]; then
    echo "Error: Failed to restore transaction log from $LOG_BACKUP_ARN."
    exit 1
  fi
done

# Finalize restore
echo "Finalizing restore..."
sqlcmd -S "$DB_INSTANCE_ENDPOINT" -U "$DB_USER" -P "$DB_PASSWORD" -C -Q "
USE master;
EXEC msdb.dbo.rds_restore_log
  @restore_db_name='$DB_NAME',
  @s3_arn_to_restore_from='${LOG_BACKUP_ARNS[-1]}',
  @with_norecovery=0;
"
if [ $? -eq 0 ]; then
  echo "Differential and transaction log restore completed successfully."
else
  echo "Error: Failed to finalize the restore."
  exit 1
fi
