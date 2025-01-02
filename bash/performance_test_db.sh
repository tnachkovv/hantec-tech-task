#!/bin/bash

# Function to display help
print_help() {
  echo "Usage: $0 --db-server <SQLServerName> --db-user <SQLUser> --db-pass <SQLPassword> --db-name <DBName>"
  echo ""
  echo "Description: Compares data integrity between an SQL Server Database and checks database performance."
  echo ""
  echo "Arguments:"
  echo "  --db-server       : SQL Server name"
  echo "  --db-user         : Database username"
  echo "  --db-pass         : Database password"
  echo "  --db-name         : Database name"
  echo "  -h, --help        : Show this help message and exit"
}

# Check if help is requested
if [[ "$1" == "--help" || "$1" == "-h" ]] || [ "$1" == "$#" ]; then
  print_help
  exit 0
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --db-server)
            DB_SERVER="$2"
            shift 2
            ;;
        --db-user)
            DB_USER="$2"
            shift 2
            ;;
        --db-pass)
            DB_PASS="$2"
            shift 2
            ;;
        --db-name)
            DB_NAME="$2"
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
if [[ -z "$DB_SERVER" || -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_NAME" ]]; then
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

    result=$(sqlcmd -S "$server" -U "$user" -P "$password" -d "$database" -h -1 -W -C -Q "$query")
    echo "$result"
}

# Function to benchmark multiple queries and log the results
benchmark_performance() {
    local server=$1
    local user=$2
    local password=$3
    local database=$4
    local query=$5
    local iterations=$6
    local log_file="performance_log.csv"

    total_time=0
    echo "Starting benchmark with $iterations iterations..."

    # Clear the log file before starting a new benchmark
    echo "Iteration,Query Time (ms)" > "$log_file"

    for i in $(seq 1 $iterations); do
        START_TIME=$(date +%s%3N)
        result=$(execute_query "$server" "$user" "$password" "$database" "$query")
        END_TIME=$(date +%s%3N)
        query_time=$((END_TIME - START_TIME))
        total_time=$((total_time + query_time))

        # Log each iteration's query time
        echo "$i,$query_time" >> "$log_file"

        echo "Query $i executed in ${query_time}ms"
    done

    avg_time=$((total_time / iterations))
    echo "Average query time: ${avg_time}ms over $iterations iterations"
    echo "Benchmark completed. Results logged in $log_file"
}

# Function to perform database stress testing with T-SQL performance tests
stress_test_sql_server() {
    echo "Running SQL Server stress test..."

    # Example of a T-SQL stress test for measuring CPU and I/O performance using a large number of random queries
    query="DECLARE @Counter INT = 0;
           WHILE @Counter < 10000
           BEGIN
               SELECT COUNT(*) FROM sys.tables;
               SET @Counter = @Counter + 1;
           END"

    # Run the stress test query and log performance
    START_TIME=$(date +%s%3N)
    result=$(execute_query "$DB_SERVER" "$DB_USER" "$DB_PASS" "$DB_NAME" "$query")
    END_TIME=$(date +%s%3N)
    stress_time=$((END_TIME - START_TIME))

    echo "Stress test completed in ${stress_time}ms"
}

# Example use of the benchmark with a complex query (aggregation)
complex_query="SELECT COUNT(*) FROM sys.tables"

# Run benchmark with 10 iterations
benchmark_performance "$DB_SERVER" "$DB_USER" "$DB_PASS" "$DB_NAME" "$complex_query" 100

# Run SQL Server stress test
stress_test_sql_server
