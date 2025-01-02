# Create IAM Role for RDS
resource "aws_iam_role" "rds_backup_role" {
  name               = "rds-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach IAM Policy to the RDS Role
resource "aws_iam_policy" "rds_backup_policy" {
  name        = "rds-backup-policy"
  description = "Policy to allow RDS to access S3 for backup and restore"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = "arn:aws:s3:::mybuckethantec"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListMultipartUploadParts", "s3:AbortMultipartUpload"]
        Resource = "arn:aws:s3:::mybuckethantec/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_backup_attach" {
  role       = aws_iam_role.rds_backup_role.name
  policy_arn = aws_iam_policy.rds_backup_policy.arn
}

# Create Option Group
resource "aws_db_option_group" "rds_option_group" {
  name                     = "mssql-express-option-group"
  engine_name              = "sqlserver-ex"
  major_engine_version     = "15.00"
  option_group_description = "Option group with BACKUP_RESTORE for MSSQL Express"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"
    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.rds_backup_role.arn
    }
  }
}

# Create DMS Role
resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role01"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dms_vpc_policy" {
  name        = "dms-vpc-policy01"
  description = "DMS VPC role policy to manage EC2 network interfaces and describe VPCs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid     = "CreateNetworkInterface"
        Effect  = "Allow"
        Action  = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute"
        ]
        Resource = [
          "arn:aws:ec2:*:682033487659:network-interface/*",
          "arn:aws:ec2:*:682033487659:instance/*",
          "arn:aws:ec2:*:682033487659:subnet/*",
          "arn:aws:ec2:*:682033487659:security-group/*"
        ]
      },
      {
        Sid     = "DescribeVPC"
        Effect  = "Allow"
        Action  = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach IAM Policy to the DMS Role
resource "aws_iam_role_policy_attachment" "dms_vpc_policy_attachment" {
  policy_arn = aws_iam_policy.dms_vpc_policy.arn
  role       = aws_iam_role.dms_vpc_role.name
}

