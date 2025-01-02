#!/bin/bash

# Help section
if [ "$#" -eq 0 ] || [ "$1" == "--help" ]; then
  echo "Usage: $0 <DBUser> <DBPassword> <DBName> <RemoteVMUser> <RemoteVMPassword> <LocalSQLServerName> <RemoteVMIp>"
  echo "Description: Performs incremental (differential) and transaction log backups of the DB SQL Database and transfers the backups to an AWS VM instance."
  echo "Arguments:"
  echo "  <DBUser>           : DB SQL Database username"
  echo "  <DBPassword>       : DB SQL Database password"
  echo "  <DBName>           : Database name"
  echo "  <VMUser>           : VM username (for SCP)"
  echo "  <VMPassword>       : VM password (for SCP)"
  echo "  <DBSQLServerName>  : DB SQL Server name"
  echo "  <DBSQLServerName>  : DB SQL Server name"
  echo "  <RemoteVMIp>       : The IP address of the Remote VM instance"
  exit 0
fi

# Set variables from arguments
DB_USER=$1
DB_PASSWORD=$2
DB_NAME=$3
VM_USER=$4
VM_PASSWORD=$5
DB_SQL_SERVER_NAME=$6
VM_IP=$7
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Set local backup paths

INCREMENTAL_BACKUP_FILE="${DB_NAME}_Incremental_${TIMESTAMP}.bak"
LOG_BACKUP_FILE="${DB_NAME}_Log_${TIMESTAMP}.bak"
LOCAL_BACKUP_PATH="/home/${VM_USER}/"
REMOTE_BACKUP_PATH="/home/${VM_USER}/"

# Perform Incremental (Differential) Backup in DB SQL Database
sqlcmd -S $DB_SQL_SERVER_NAME -d master -U $DB_USER -P $DB_PASSWORD -C -Q "
BACKUP DATABASE $DB_NAME
TO DISK = N'$LOCAL_BACKUP_PATH$INCREMENTAL_BACKUP_FILE'
WITH DIFFERENTIAL, COMPRESSION;
"

# Perform Transaction Log Backup in DB SQL Database
sqlcmd -S $DB_SQL_SERVER_NAME -d master -U $DB_USER -P $DB_PASSWORD -C -Q "
BACKUP LOG $DB_NAME
TO DISK = N'$LOCAL_BACKUP_PATH$LOG_BACKUP_FILE'
WITH COMPRESSION;
"

# Check if the backups were successful
if [ $? -ne 0 ]; then
  echo "Incremental or log backup failed!"
  exit 1
fi

# Transfer the backup files to AWS VM
echo "Transferring incremental and log backups to AWS VM..."
sshpass -p $VM_PASSWORD scp $LOCAL_BACKUP_PATH$INCREMENTAL_BACKUP_FILE $VM_USER@$VM_IP:$REMOTE_BACKUP_PATH
sshpass -p $VM_PASSWORD scp $LOCAL_BACKUP_PATH$LOG_BACKUP_FILE $VM_USER@$VM_IP:$REMOTE_BACKUP_PATH

# Check if SCP transfer was successful
if [ $? -ne 0 ]; then
  echo "File transfer to AWS VM failed!"
  exit 1
fi

echo "Incremental and transaction log backups transferred successfully!"
