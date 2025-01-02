#!/bin/bash

# Help section
if [ "$#" -eq 0 ] || [ "$1" == "--help" ]; then
          echo "Usage: $0 <DBUser> <DBPassword> <DBName> <RemoteVMUser> <RemoteVMPassword> <LocalSQLServerName> <RemoteVMIp>"
          echo "Description: Performs a full BAK export of specific Database and transfers the backup to an VM instance."
          echo "Arguments:"
          echo "  <DBUser>                 : Local SQL Database username"
          echo "  <DBPassword>             : Local SQL Database password"
          echo "  <DBName>                 : Database name"
          echo "  <RemoteVMUser>           : Remote VM username (for SCP)"
          echo "  <RemoteVMPassword>       : Remote VM password (for SCP)"
          echo "  <LocalSQLServerName>     : Local SQL Server name"
          echo "  <RemoteVMIp>             : The IP address of the Remote VM instance"
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
BACKUP_FILE="${DB_NAME}_Full_${TIMESTAMP}.bak"
LOCAL_BACKUP_PATH="/home/$VM_USER/$BACKUP_FILE"
REMOTE_BACKUP_PATH="/home/$VM_USER/$BACKUP_FILE"

# Perform Full Backup in DB SQL Database
sqlcmd -S $DB_SQL_SERVER_NAME -d master -U $DB_USER -P $DB_PASSWORD -C -Q "
BACKUP DATABASE $DB_NAME
TO DISK = N'$LOCAL_BACKUP_PATH'
WITH COMPRESSION;
"

# Check if the backup was successful
if [ $? -ne 0 ]; then
  echo "Full backup failed!"
  exit 1
fi

# Verify the backup using RESTORE VERIFYONLY
sqlcmd -S $DB_SQL_SERVER_NAME -d master -U $DB_USER -P $DB_PASSWORD -C -Q "
RESTORE VERIFYONLY FROM DISK = N'$LOCAL_BACKUP_PATH';
"

# Check if the verification was successful
if [ $? -ne 0 ]; then
  echo "Backup verification failed! The backup file may be corrupted."
  exit 1
fi

# Transfer the backup file to Remote VM via SCP
echo "Transferring full backup to Remote VM..."
sshpass -p $VM_PASSWORD scp $LOCAL_BACKUP_PATH $VM_USER@$VM_IP:$REMOTE_BACKUP_PATH

# Check if SCP transfer was successful
if [ $? -ne 0 ]; then
  echo "File transfer to Remote VM failed!"
  exit 1
fi

echo "Full backup, verification, and transfer completed successfully!"
