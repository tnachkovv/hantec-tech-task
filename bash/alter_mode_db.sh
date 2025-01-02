#!/bin/bash

# Help section
if [ "$#" -eq 0 ] || [ "$1" == "--help" ]; then
  echo "Usage: $0 <DBEndpoint> <DBUser> <DBPassword> <DBName> <Mode>"
  echo "Description: Alters the database mode between READ_ONLY or READ_WRITE on DB RDS."
  echo "Arguments:"
  echo "  <DBEndpoint>       : DB Endpoint"
  echo "  <DBUser>           : RDS username"
  echo "  <DBPassword>       : DB password"
  echo "  <DBName>           : Database name"
  echo "  <Mode>             : Mode to set (READ_ONLY or READ_WRITE)"
  exit 0
fi

# Set variables from arguments
DB_ENDPOINT=$1
DB_USER=$2
DB_PASSWORD=$3
DB_NAME=$4
MODE=$5

if [ "$MODE" == "READ_ONLY" ]; then
  # Alter database to READ_ONLY
  sqlcmd -S $DB_ENDPOINT -d master -U $DB_USER -P $DB_PASSWORD -C -Q "
  ALTER DATABASE $DB_NAME SET READ_ONLY;
  "
elif [ "$MODE" == "READ_WRITE" ]; then
  # Alter database to READ_WRITE
  sqlcmd -S $DB_ENDPOINT -d master -U $DB_USER -P $DB_PASSWORD -C -Q "
  ALTER DATABASE $DB_NAME SET READ_WRITE;
  "
else
  echo "Invalid mode. Please choose either READ_ONLY or READ_WRITE."
  exit 1
fi

echo "Database mode changed to $MODE successfully!"