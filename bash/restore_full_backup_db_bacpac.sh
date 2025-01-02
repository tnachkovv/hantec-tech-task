#!/bin/bash

# Help section
if [ "$#" -eq 0 ] || [ "$1" == "--help" ]; then
  echo "Usage: $0 <DBUser> <DBPassword> <DBName> <DBSQLServerName> <FileBackupLocation>"
  echo "Description: Restores a BACPAC file to a DB SQL Database (RDS for SQL Server)."
  echo "Arguments:"
  echo "  <DBUser>           : DB SQL Database username"
  echo "  <DBPassword>       : DB SQL Database password"
  echo "  <DBName>           : Database name to restore"
  echo "  <DBSQLServerName>  : DB SQL Server name (RDS endpoint)"
  echo "  <FileBackupLocation>: Full path to the BACPAC file"
  exit 0
fi
# Set variables from arguments
DB_USER=$1
DB_PASSWORD=$2
DB_NAME=$3
DB_SQL_SERVER_NAME=$4
BACPAC_FILE_PATH=$5

# Check if BACPAC file exists
if [ ! -f "$BACPAC_FILE_PATH" ]; then
  echo "BACPAC file not found at the specified location: $BACPAC_FILE_PATH"
  exit 1
fi

# Restore the database from the BACPAC file using sqlpackage
echo "Restoring database $DB_NAME from BACPAC file..."
sqlpackage /Action:Import \
           /sf:$BACPAC_FILE_PATH \
           /tsn:$DB_SQL_SERVER_NAME \
           /tdn:$DB_NAME \
           /tu:$DB_USER \
           /tp:$DB_PASSWORD \
           /TargetTrustServerCertificate:true

# Check if the restore was successful
if [ $? -ne 0 ]; then
  echo "BACPAC restore failed!"
  exit 1
fi

echo "BACPAC restore completed successfully!"
