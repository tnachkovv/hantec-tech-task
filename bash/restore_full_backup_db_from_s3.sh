#!/bin/bash

# Help section
function print_help {
  echo "Usage: $0 <DBUser> <DBPassword> <DBName> <DBInstanceEndpoint> <S3BackupArn>"
  echo "Description: Restores the full backup to the database and leaves it in NORECOVERY mode."
  echo "Arguments:"
  echo "  <DBUser>             : DB username"
  echo "  <DBPassword>         : DB password"
  echo "  <DBName>             : Database name"
  echo "  <DBInstanceEndpoint> : DB instance endpoint"
  echo "  <S3BackupArn>        : ARN of the full backup in S3"
  exit 1
}

# Check if help is requested or arguments are missing
if [ "$1" == "--help" ] || [ "$#" -ne 5 ]; then
  print_help
fi

# Set variables from arguments
DB_USER=$1
DB_PASSWORD=$2
DB_NAME=$3
DB_INSTANCE_ENDPOINT=$4
S3_BACKUP_ARN=$5

# Restore full backup with NORECOVERY
echo "Restoring full backup..."
sqlcmd -S "$DB_INSTANCE_ENDPOINT" -U "$DB_USER" -P "$DB_PASSWORD" -C -Q "
USE master;
EXEC msdb.dbo.rds_restore_database
  @restore_db_name='$DB_NAME',
  @s3_arn_to_restore_from='$S3_BACKUP_ARN',
  @with_norecovery=1,
  @type='FULL';
"
if [ $? -eq 0 ]; then
  echo "Full backup restore initiated successfully."
else
  echo "Error: Failed to restore full backup."
  exit 1
fi
