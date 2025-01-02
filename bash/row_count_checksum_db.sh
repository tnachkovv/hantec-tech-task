#!/bin/bash

# Function to display help
print_help() {
  echo "Usage: $0 --azure-server <AzureSQLServerName> --azure-user <AzureUser> --azure-pass <AzurePassword> --azure-db <DBName> --aws-server <AWS_MSSQLServerName> --aws-user <AWSUser> --aws-pass <AWSPassword> --aws-db <AWSDBName>"
  echo ""
  echo "Description: Compares data between an Azure SQL Database and an AWS MSSQL Database, checking row counts and checksums for each table."
  echo ""
  echo "Arguments:"
  echo "  --azure-server       : Azure SQL Server name"
  echo "  --azure-user         : Azure SQL Database username"
  echo "  --azure-pass         : Azure SQL Database password"
  echo "  --azure-db           : Azure SQL Database name"
  echo "  --aws-server         : AWS MSSQL Server name"
  echo "  --aws-user           : AWS MSSQL username"
  echo "  --aws-pass           : AWS MSSQL password"
  echo "  --aws-db             : AWS MSSQL Database name"
  echo "  -h, --help           : Show this help message and exit"
}

# Check if help is requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  print_help
  exit 0
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --azure-server)
            AZURE_SERVER="$2"
            shift 2
            ;;
        --azure-user)
            AZURE_USER="$2"
            shift 2
            ;;
        --azure-pass)
            AZURE_PASS="$2"
            shift 2
            ;;
        --azure-db)
            AZURE_DB="$2"
            shift 2
            ;;
        --aws-server)
            AWS_SERVER="$2"
            shift 2
            ;;
        --aws-user)
            AWS_USER="$2"
            shift 2
            ;;
        --aws-pass)
            AWS_PASS="$2"
            shift 2
            ;;
        --aws-db)
            AWS_DB="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

# Ensure all variables are set
if [[ -z "$AZURE_SERVER" || -z "$AZURE_USER" || -z "$AZURE_PASS" || -z "$AZURE_DB" || -z "$AWS_SERVER" || -z "$AWS_USER" || -z "$AWS_PASS" || -z "$AWS_DB" ]]; then
    echo "Error: Missing required arguments."
    print_help
    exit 1
fi

# Function to execute a query and return results
execute_query() {
    local server=$1
    local user=$2
    local password=$3
    local database=$4
    local query=$5

    result=$(sqlcmd -S "$server" -U "$user" -P "$password" -d "$database" -h -1 -W -C -Q "$query" | grep -v "rows affected" | sed '/^\s*$/d')
    echo "$result"
}

# Step 1: Retrieve table names from Azure (source)
echo "Fetching table names from Azure database..."
TABLES=$(execute_query "$AZURE_SERVER" "$AZURE_USER" "$AZURE_PASS" "$AZURE_DB" "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';")

# Convert table names to an array
IFS=$'\n' read -r -d '' -a TABLES_ARRAY <<<"$TABLES"

# Function to compare data integrity for each table
compare_tables() {
    local table=$1
    echo "Processing table: $table"

    # Query row count from Azure
    ROW_COUNT_QUERY="SELECT COUNT(*) FROM $table"
    azure_row_count=$(execute_query "$AZURE_SERVER" "$AZURE_USER" "$AZURE_PASS" "$AZURE_DB" "$ROW_COUNT_QUERY")
    echo "Azure row count for $table: $azure_row_count"

    # Query row count from AWS
    aws_row_count=$(execute_query "$AWS_SERVER" "$AWS_USER" "$AWS_PASS" "$AWS_DB" "$ROW_COUNT_QUERY")
    echo "AWS row count for $table: $aws_row_count"

    # Query checksum from Azure
    CHECKSUM_QUERY="SELECT CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM $table"
    azure_checksum=$(execute_query "$AZURE_SERVER" "$AZURE_USER" "$AZURE_PASS" "$AZURE_DB" "$CHECKSUM_QUERY")
    echo "Azure checksum for $table: $azure_checksum"

    # Query checksum from AWS
    aws_checksum=$(execute_query "$AWS_SERVER" "$AWS_USER" "$AWS_PASS" "$AWS_DB" "$CHECKSUM_QUERY")
    echo "AWS checksum for $table: $aws_checksum"

    # Compare row counts
    if [[ "$azure_row_count" -eq "$aws_row_count" ]]; then
        echo "✔ Row count matches for $table."
    else
        echo "✘ Row count mismatch for $table! Azure: $azure_row_count, AWS: $aws_row_count"
    fi

    # Compare checksums
    if [[ "$azure_checksum" == "$aws_checksum" ]]; then
        echo "Checksum matches for $table."
    else
        echo "Checksum mismatch for $table! Azure: $azure_checksum, AWS: $aws_checksum"
    fi

    echo "-----------------------------------------"
}

# Loop through all tables and compare data
for table in "${TABLES_ARRAY[@]}"; do
    compare_tables "$table"
done