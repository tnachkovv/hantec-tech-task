#!/bin/bash

# Help section
if [ "$#" -eq 0 ] || [ "$1" == "--help" ]; then          
echo "Usage: $0 <DBUser> <DBPassword> <DBName> <RemoteVMUser> <RemoteVMPassword> <LocalSQLServerName> <RemoteVMIp>"
          echo "Description: Performs a full BACPAC export of the DB SQL Database and transfers the backup to an Remote VM instance."
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
BACPAC_FILE="${DB_NAME}_Full_${TIMESTAMP}.bacpac"
LOCAL_BACKUP_PATH="/home/$VM_USER/$BACPAC_FILE"
REMOTE_BACKUP_PATH="/home/$VM_USER/$BACPAC_FILE"

# Export database as BACPAC file using sqlpackage
echo "Exporting database as BACPAC file..."
sqlpackage /Action:Export \
                   /TargetFile:$LOCAL_BACKUP_PATH \
                   /SourceServerName:$DB_SQL_SERVER_NAME \
                   /SourceDatabaseName:$DB_NAME \
                   /SourceUser:$DB_USER \
                   /SourcePassword:$DB_PASSWORD

# Check if the export was successful
if [ $? -ne 0 ]; then
          echo "BACPAC export failed!"
            exit 1
fi

# Verify the BACPAC file (Optional step: checks for file existence and size)
if [ ! -f $LOCAL_BACKUP_PATH ] || [ ! -s $LOCAL_BACKUP_PATH ]; then
          echo "BACPAC file verification failed! The file may not exist or is empty."
            exit 1
fi

# Transfer the BACPAC file to Remote VM via SCP
echo "Transferring BACPAC file to AWS VM..."
sshpass -p $VM_PASSWORD scp $LOCAL_BACKUP_PATH $VM_USER@$VM_IP:$REMOTE_BACKUP_PATH

# Check if SCP transfer was successful
if [ $? -ne 0 ]; then
          echo "File transfer to AWS VM failed!"
            exit 1
fi

echo "BACPAC export, verification, and transfer completed successfully!"
