# Bash Scripts for Database Migration Automation

## Overview
In order to automate some of the activities during the migration process, the following bash scripts were created. All of the scripts should be executed on either the AWS or Azure Agents, depending on the occasion.

- **row_count_checksum_db**: A bash script used for comparing the rows of each table and the checksums from specific databases at two different locations. It can be executed on both Azure or AWS agents and requires connection to both database instances.
- **performance_test_db**: A bash script used to execute a large number of READ operations in a specific database. It performs the following activities:
  - Performs 100 read operations, measures execution time for each operation in milliseconds, saves the results in a `.csv` file, and prints the average execution time.
  - Performs 1000 read operations and measures the average total execution time in milliseconds.
- **alter_mode_db**: A bash script used for setting the mode of a specific database to `READ_ONLY` or `WRITE_READ`.
- **create_full_backup_db**: A bash script that creates a full backup using the native `backup-restore` mechanism from a specific database and transfers the backup file to a remote host using `scp`. The backup file has a `.bak` extension and supports differential backups and transaction logs. It can be used against Azure VM SQL instances as well as Azure SQL Managed Instances (but not Azure SQL Databases).
- **create_full_backup_db_bacpac**: A bash script that creates a full backup using the `sqlpackage` tool from a specific database and transfers the backup file using `scp`. The backup file has a `.bacpac` extension and does not support differential backups.
- **create_incremental_backup_db**: Similar to `create_full_backup_db_s3`, but used for creating incremental backups. The backup file has a `.bak` extension and supports differential backups and transaction logs. It works with Azure VM SQL Instances and Azure SQL Managed Instances (but not Azure SQL Databases).
- **restore_full_backup_db_bacpac**: A bash script used for restoring a full backup using the `sqlpackage` tool from a specific database. The backup file has a `.bacpac` extension and is meant to be executed against an AWS RDS SQL server.
- **restore_full_backup_db_from_s3**: A bash script used for restoring a full backup using the native `backup-restore` mechanism to a specific database. The backup file has a `.bak` extension and supports differential backups and transaction logs. It is meant for AWS RDS SQL servers that have an IAM role for backup/restore to/from S3.
- **restore_incremental_backup_db_from_s3**: A bash script used for restoring differential backups and transaction logs using the native `backup-restore` mechanism to a specific database. The backup file has a `.bak` extension and is used for AWS RDS SQL servers with an IAM role for backup/restore from S3.

## Prerequisites
- **Linux OS**: The scripts have been tested on RHEL 9 EC2/Azure VMs. They may work on other Linux distributions, but some inconsistencies might occur.
- **Required Packages**: 
  - `sqlpackage`, `sqlcmd`, `sshpass` need to be installed on the Linux agent before execution.

## Usage

### 1. **row_count_checksum_db**
```bash
$ ./row_count_checksum_db.sh
Usage: ./row_count_checksum_db.sh --azure-server <AzureSQLServerName> --azure-user <AzureUser> --azure-pass <AzurePassword> --azure-db <DBName> --aws-server <AWS_MSSQLServerName> --aws-user <AWSUser> --aws-pass <AWSPassword> --aws-db <AWSDBName>
Description: Compares data between an Azure SQL Database and an AWS MSSQL Database, checking row counts and checksums for each table.

Arguments:
  --azure-server       : Azure SQL Server name
  --azure-user         : Azure SQL Database username
  --azure-pass         : Azure SQL Database password
  --azure-db           : Azure SQL Database name
  --aws-server         : AWS MSSQL Server name
  --aws-user           : AWS MSSQL username
  --aws-pass           : AWS MSSQL password
  --aws-db             : AWS MSSQL Database name
  -h, --help           : Show this help message and exit
   ```
### 2. **performance_test_db**
```bash
$ ./performance_test_db.sh
Usage: ./performance_test_db.sh --db-server <SQLServerName> --db-user <SQLUser> --db-pass <SQLPassword> --db-name <DBName>

Description: Compares data integrity between an SQL Server Database and checks database performance.

Arguments:
  --db-server       : SQL Server name
  --db-user         : Database username
  --db-pass         : Database password
  --db-name         : Database name
  -h, --help        : Show this help message and exit
   ```

### 3. **alter_mode_db**
```bash
./alter_mode_db.sh
Usage: ./alter_mode_db.sh <DBEndpoint> <DBUser> <DBPassword> <DBName> <Mode>
Description: Alters the database mode between READ_ONLY or READ_WRITE on DB RDS.
Arguments:
  <DBEndpoint>       : DB Endpoint
  <DBUser>           : RDS username
  <DBPassword>       : DB password
  <DBName>           : Database name
  <Mode>             : Mode to set (READ_ONLY or READ_WRITE)
   ```

### 4. **create_full_backup_db**
```bash
$ ./create_full_backup_db.sh
Usage: ./create_full_backup_db.sh <DBUser> <DBPassword> <DBName> <RemoteVMUser> <RemoteVMPassword> <LocalSQLServerName> <RemoteVMIp>
Description: Performs a full BAK export of specific Database and transfers the backup to an VM instance.
Arguments:
  <DBUser>                 : Local SQL Database username
  <DBPassword>             : Local SQL Database password
  <DBName>                 : Database name
  <RemoteVMUser>           : Remote VM username (for SCP)
  <RemoteVMPassword>       : Remote VM password (for SCP)
  <LocalSQLServerName>     : Local SQL Server name
  <RemoteVMIp>             : The IP address of the Remote VM instance
   ```

### 5. **create_full_backup_db_bacpac**
```bash
$ ./create_full_backup_db.sh
Usage: ./create_full_backup_db.sh <DBUser> <DBPassword> <DBName> <RemoteVMUser> <RemoteVMPassword> <LocalSQLServerName> <RemoteVMIp>
Description: Performs a full BAK export of specific Database and transfers the backup to an VM instance.
Arguments:
  <DBUser>                 : Local SQL Database username
  <DBPassword>             : Local SQL Database password
  <DBName>                 : Database name
  <RemoteVMUser>           : Remote VM username (for SCP)
  <RemoteVMPassword>       : Remote VM password (for SCP)
  <LocalSQLServerName>     : Local SQL Server name
  <RemoteVMIp>             : The IP address of the Remote VM instance
   ```

### 6. **create_incremental_backup_db**
```bash
$ ./create_full_backup_db.sh
Usage: ./create_full_backup_db.sh <DBUser> <DBPassword> <DBName> <RemoteVMUser> <RemoteVMPassword> <LocalSQLServerName> <RemoteVMIp>
Description: Performs a full BAK export of specific Database and transfers the backup to an VM instance.
Arguments:
  <DBUser>                 : Local SQL Database username
  <DBPassword>             : Local SQL Database password
  <DBName>                 : Database name
  <RemoteVMUser>           : Remote VM username (for SCP)
  <RemoteVMPassword>       : Remote VM password (for SCP)
  <LocalSQLServerName>     : Local SQL Server name
  <RemoteVMIp>             : The IP address of the Remote VM instance
   ```

### 7. **restore_full_backup_db_bacpac**
```bash
$ ./restore_full_backup_db_bacpac.sh
Usage: ./restore_full_backup_db_bacpac.sh <DBUser> <DBPassword> <DBName> <DBSQLServerName> <FileBackupLocation>
Description: Restores a BACPAC file to a DB SQL Database (RDS for SQL Server).
Arguments:
  <DBUser>           : DB SQL Database username
  <DBPassword>       : DB SQL Database password
  <DBName>           : Database name to restore
  <DBSQLServerName>  : DB SQL Server name (RDS endpoint)
  <FileBackupLocation>: Full path to the BACPAC file
   ```

### 8. **restore_full_backup_db_from_s3**
```bash
$ ./restore_full_backup_db_from_s3.sh
Usage: ./restore_full_backup_db_from_s3.sh <DBUser> <DBPassword> <DBName> <DBInstanceEndpoint> <S3BackupArn>
Description: Restores the full backup to the database and leaves it in NORECOVERY mode.
Arguments:
  <DBUser>             : DB username
  <DBPassword>         : DB password
  <DBName>             : Database name
  <DBInstanceEndpoint> : DB instance endpoint
  <S3BackupArn>        : ARN of the full backup in S3
   ```
   
### 9. **restore_incremental_backup_db_from_s3**
```bash
$ ./restore_incremental_backup_db_from_s3.sh
Usage: ./restore_incremental_backup_db_from_s3.sh <DBUser> <DBPassword> <DBName> <DBInstanceEndpoint> <S3DiffBackupArn> <S3LogBackupArns>
Description: Restores the differential backup and transaction logs to the database.
Arguments:
  <DBUser>             : DB username
  <DBPassword>         : DB password
  <DBName>             : Database name
  <DBInstanceEndpoint> : DB instance endpoint
  <S3DiffBackupArn>    : ARN of the differential backup in S3
  <S3LogBackupArns>    : Comma-separated ARNs of transaction log backups in S3
   ```
