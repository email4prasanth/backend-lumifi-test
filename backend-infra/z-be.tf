### File: backend.tf ###
# Terraform Remote Backend Configuration - S3 for backend code 
terraform {
  backend "s3" {
    bucket  = "lumifitfstore"
    key     = "backend/terraform.tfstate"
    region  = "us-east-1"
    # profile = "lumifitest"
  }
}


### File: data_sources.tf ###
# # Reuse existing VPC instead of creating a new one
# data "aws_vpc" "existing" {
# #   count = terraform.workspace == "prod" ? 1 : 0
#   filter {
#     name   = "tag:Name"
#     values = ["lumifitest-vpc"]
#   }
# }
# # reuse existing subnets
# data "aws_subnets" "existing" {
#   count = terraform.workspace == "prod" ? 1 : 0
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.existing[0].id]
#   }
# }
# # Public Route Table
# data "aws_route_tables" "existing" {
#   count = terraform.workspace == "prod" ? 1 : 0

#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.existing[0].id]
#   }

#   filter {
#     name   = "tag:Tier"
#     values = ["public"]
#   }
# }
# # Private Route Table
# data "aws_route_tables" "existing_private" {
#   count = terraform.workspace == "prod" ? 1 : 0

#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.existing[0].id]
#   }

#   filter {
#     name   = "tag:Tier"
#     values = ["private"]
#   }
# }


### File: iam.tf ###
# # IAM Role for Lambda Execution
# resource "aws_iam_role" "lambda_role" {
#   name = "${local.project_name.name}-${terraform.workspace}-lambda-exec-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = [
#         "sts:AssumeRole"
#       ]
#       Effect = "Allow"
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }

# # Attach AWS Managed Policies to Lambda Role
# resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }
# resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }
# resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# }
# resource "aws_iam_role_policy_attachment" "lambda_rds_ssl" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
# }


### File: kms.tf ###
resource "aws_kms_key" "lumifi_cmk" {
  description             = "Lumifi CMK for encrypting RDS and other sensitive data"
  deletion_window_in_days = 30
  enable_key_rotation     = true


  policy = <<POLICY
{
"Version": "2012-10-17",
"Id": "key-default-1",
"Statement": [
{
"Sid": "Enable IAM User Permissions",
"Effect": "Allow",
"Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
"Action": "kms:*",
"Resource": "*"
}
]
}
POLICY
}


resource "aws_kms_alias" "lumifi_alias" {
  name          = "alias/${local.project_name.name}-${terraform.workspace}-cmk"
  target_key_id = aws_kms_key.lumifi_cmk.key_id
}



### File: locals.tf ###
locals {
  aws_region = "us-east-1"
  vpc_name   = "lumifitest-vpc"
  # Tags, VPC CIDR, Availability Zones Configuration for Dev and Prod Environment
  tags = {
    owner       = "lumifitest"
    environment = terraform.workspace
  }
  project_name = {
    name = "lumifitest"
  }
  cidr_ranges = {
    "dev"  = "10.60.0.0/16"
    "prod" = "10.61.0.0/16"
  }
  vpc_cidr = lookup(local.cidr_ranges, terraform.workspace, "10.60.0.0/16")
  az = {
    "dev"  = ["us-east-1a", "us-east-1b"] # Two AZs but deploy RDS in single AZ for DEV
    "prod" = ["us-east-1a", "us-east-1b"] # Two AZs with Multi-AZ deployment for PROD
  }
  avail_zones = lookup(local.az, terraform.workspace, ["us-east-1a"])

  # Security Group Rules for Dev and Prod Environment
  security_group_rules = {
    "dev" = [
      # {
      #   type        = "ingress"
      #   description = "Allow SSH inbound traffic"
      #   from_port   = 22
      #   to_port     = 22
      #   protocol    = "tcp"
      #   cidr_blocks = ["0.0.0.0/0"]
      # },
      # {
      #   type        = "ingress"
      #   description = "Allow HTTP inbound traffic"
      #   from_port   = 80
      #   to_port     = 80
      #   protocol    = "tcp"
      #   cidr_blocks = ["0.0.0.0/0"]
      # },
      {
        type        = "ingress"
        description = "Allow all inbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        type        = "egress"
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    "prod" = [
      {
        type        = "ingress"
        description = "Allow SSH inbound traffic"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        type        = "ingress"
        description = "Allow HTTP inbound traffic"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        type        = "ingress"
        description = "Allow HTTPS inbound traffic"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        type        = "egress"
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  sg = lookup(local.security_group_rules, terraform.workspace, local.security_group_rules["dev"])

  # RDS Configuration for Dev and Prod Environment
  db_config = {
    "dev" = {
      allocated_storage = 20
    }
    "prod" = {
      allocated_storage = 100
    }
  }
  rds = lookup(local.db_config, terraform.workspace, local.db_config["dev"])

  # ses_config = {
  #   "dev"  = { email_limit = 10000 }
  #   "prod" = { email_limit = 25000 }
  # }
  # glacier_config = {
  #   "dev"  = { storage_gb = 10, requests = 1000 }
  #   "prod" = { storage_gb = 100, requests = 10000 }
  # }
  sender_email   = "reachtechprasanth@gmail.com"
  receiver_email = "marriprasanth.p@hubino.com"

  api_root_path = "api/v1"

}








### File: outputs.tf ###
# outputs.tf (in Terraform)
output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "subnet_ids" {
  value = join(",", terraform.workspace == "prod" ? data.aws_subnets.existing[0].ids : aws_subnet.lumifi_subnets[*].id)
}

# # Example Terraform outputs
# output "rds_endpoint" {
#   value = aws_db_instance.postgres.endpoint
# }

# # Conditional RDS endpoint output
# output "rds_endpoint" {
#   description = "RDS endpoint based on environment"
#   value = var.deploy_public_rds ? (
#     aws_db_instance.postgres[0].endpoint
#     ) : (
#     var.deploy_private_rds ? aws_db_instance.postgres_private[0].endpoint : null
#   )
# }

# output "rds_type" {
#   description = "Type of RDS deployed"
#   value = var.deploy_public_rds ? "public" : (
#     var.deploy_private_rds ? "private" : "none"
#   )
# }
# ------------------------------
# 🌐 VPC Outputs
# ------------------------------
output "vpc_id" {
  value = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id
}

output "vpc_name" {
  value = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].tags["Name"] : data.aws_vpc.existing[0].tags["Name"]
}

# ------------------------------
# Public Subnets Outputs
# ------------------------------
output "public_subnet_ids" {
  value = terraform.workspace == "dev" ? aws_subnet.lumifi_subnets[*].id : data.aws_subnets.public[0].ids
}

output "public_subnet_names" {
  value = terraform.workspace == "dev" ? [for s in aws_subnet.lumifi_subnets : s.tags["Name"]] : [for s in data.aws_subnets.public[0].ids : s]
}

output "internet_gateway_id" {
  value = terraform.workspace == "dev" ? aws_internet_gateway.lumifi-igw[0].id : data.aws_internet_gateway.existing[0].id
}

output "internet_gateway_name" {
  value = terraform.workspace == "dev" ? aws_internet_gateway.lumifi-igw[0].tags["Name"] : data.aws_internet_gateway.existing[0].tags["Name"]
}

output "public_route_table_id" {
  value = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].id : data.aws_route_tables.public[0].ids[0]
}

output "public_route_table_name" {
  value = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].tags["Name"] : data.aws_route_tables.public[0].tags["Name"]
}

# ------------------------------
# Private Subnets Outputs
# ------------------------------
output "private_subnet_ids" {
  value = terraform.workspace == "dev" ? aws_subnet.lumifi_private_subnets[*].id : data.aws_subnets.private[0].ids
}

output "private_subnet_names" {
  value = terraform.workspace == "dev" ? [for s in aws_subnet.lumifi_private_subnets : s.tags["Name"]] : [for s in data.aws_subnets.private[0].ids : s]
}

output "private_route_table_id" {
  value = terraform.workspace == "dev" ? aws_route_table.private_rt[0].id : data.aws_route_tables.private[0].ids[0]
}

output "private_route_table_name" {
  value = terraform.workspace == "dev" ? aws_route_table.private_rt[0].tags["Name"] : data.aws_route_tables.private[0].tags["Name"]
}


# ------------------------------
# 🔒 Security Groups
# ------------------------------
output "lumifi_security_group_name" {
  description = "Main Lumifi Security Group name"
  value       = aws_security_group.lumifi_sg.tags["Name"]
}

output "lambda_security_group_name" {
  description = "Lambda Security Group name"
  value       = aws_security_group.lambda_sg.tags["Name"]
}

output "rds_security_group_name" {
  description = "Public RDS Security Group name"
  value       = var.deploy_public_rds ? aws_security_group.rds[0].name : null
}

output "rds_private_security_group_name" {
  description = "Private RDS Security Group name"
  value       = var.deploy_private_rds ? aws_security_group.rds_private[0].name : null
}

# ------------------------------
# 🗄️ S3 Buckets
# ------------------------------
output "backend_bucket_name" {
  description = "S3 bucket for backend data"
  value       = aws_s3_bucket.backend.bucket
}

output "logs_bucket_name" {
  description = "S3 bucket for logs"
  value       = aws_s3_bucket.logs.bucket
}

# ------------------------------
# 🔑 KMS
# ------------------------------
output "kms_key_alias" {
  description = "Alias name of the KMS key"
  value       = aws_kms_alias.lumifi_alias.name
}

output "kms_key_arn" {
  description = "ARN of the Lumifi KMS CMK"
  value       = aws_kms_key.lumifi_cmk.arn
}

# ------------------------------
# 🧰 RDS (Public / Private)
# ------------------------------
output "rds_instance_name" {
  description = "Identifier of the RDS instance"
  value = var.deploy_public_rds ? (
    aws_db_instance.postgres[0].identifier
    ) : (
    var.deploy_private_rds ? aws_db_instance.postgres_private[0].identifier : null
  )
}

output "rds_endpoint" {
  description = "Endpoint of the active RDS instance"
  value = var.deploy_public_rds ? (
    aws_db_instance.postgres[0].endpoint
    ) : (
    var.deploy_private_rds ? aws_db_instance.postgres_private[0].endpoint : null
  )
}

output "rds_type" {
  description = "Type of RDS deployed (public/private/none)"
  value = var.deploy_public_rds ? "public" : (
    var.deploy_private_rds ? "private" : "none"
  )
}

# ------------------------------
# 🔐 Secrets Manager
# ------------------------------
output "rds_secret_name" {
  description = "RDS credentials secret name"
  value = var.deploy_public_rds ? (
    aws_secretsmanager_secret.rds_credentials[0].name
    ) : (
    var.deploy_private_rds ? aws_secretsmanager_secret.rds_credentials_pvt[0].name : null
  )
}


### File: providers.tf ###
# Add this data source
data "aws_caller_identity" "current" {}

# Terraform Block with Required Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# AWS Provider Configuration
provider "aws" {
  region  = local.aws_region
  # profile = "lumifitest"
}


### File: public_rds.tf ###

# RDS Subnet Group (Using Public Subnets)
resource "aws_db_subnet_group" "public_db" {
  count = var.deploy_public_rds ? 1 : 0

  name       = "${terraform.workspace}-lumifi-public-db-subnet-group"
  subnet_ids = terraform.workspace == "dev" ? aws_subnet.lumifi_subnets[*].id : data.aws_subnets.public[0].ids

  tags = merge(local.tags, {
    Name = "${terraform.workspace}-db-subnet-group"
  })
}

# PostgreSQL RDS Instance with KMS Encryption
resource "aws_db_instance" "postgres" {
  count = var.deploy_public_rds ? 1 : 0

  identifier        = "${terraform.workspace}-lumifi-db"
  allocated_storage = local.rds.allocated_storage
  storage_type      = "gp3"
  engine            = "postgres"
  engine_version    = "15"
  # Updated instance types per environment and Multi-AZ configuration
  #   instance_class            = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.small"
  instance_class            = terraform.workspace == "prod" ? "db.t3.small" : "db.t3.small"
  multi_az                  = terraform.workspace == "prod" ? true : false
  db_name                   = "${terraform.workspace}_lumifi"
  username                  = "dbadmin"
  password                  = random_password.db_admin_password.result
  parameter_group_name      = "default.postgres15"
  skip_final_snapshot       = terraform.workspace == "dev" ? true : false
  final_snapshot_identifier = terraform.workspace == "prod" ? "${terraform.workspace}-lumifi-db-final-snapshot" : null
  # vpc_security_group_ids    = [aws_security_group.rds.id]
  # db_subnet_group_name      = aws_db_subnet_group.public_db.name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  db_subnet_group_name   = aws_db_subnet_group.public_db[0].name
  publicly_accessible    = true
  apply_immediately      = true
  # Added KMS, backup, and deletion protection settings
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.lumifi_cmk.arn
  backup_retention_period = 7
  deletion_protection     = false
  tags                    = local.tags
  depends_on = [
    aws_internet_gateway.lumifi-igw[0],
    aws_route_table.lumifi-pub-rt,
    aws_security_group.lumifi_sg
  ]
}


# # PostgreSQL RDS Instance
# resource "aws_db_instance" "postgres" {
#   identifier        = "${terraform.workspace}-lumifi-db"
#   allocated_storage = local.rds.allocated_storage
#   storage_type      = "gp3"
#   engine            = "postgres"
#   engine_version    = "15"
#   # Updated instance types per environment
#   # instance_class = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.small"
#   instance_class = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.micro" # For testing
#   # Multi-AZ configuration
#   multi_az               = terraform.workspace == "prod" ? true : false
#   db_name                = "${terraform.workspace}_lumifi"
#   username               = "dbadmin"
#   password               = random_password.db_admin_password.result
#   # parameter_group_name   = "default.postgres15"
#   parameter_group_name   = aws_db_parameter_group.lumifi_pg.name
#   skip_final_snapshot    = terraform.workspace == "dev" ? true : false
#   vpc_security_group_ids = [aws_security_group.rds.id]
#   db_subnet_group_name   = aws_db_subnet_group.public_db.name
#   publicly_accessible    = true
#   apply_immediately      = true
#   tags                   = local.tags
#   depends_on = [
#     aws_internet_gateway.lumifi-igw[0],
#     aws_route_table.lumifi-pub-rt,
#     aws_security_group.lumifi_sg
#   ]
# }


### File: public_secrets.tf ###
# Secrets Manager - RDS Credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  count = var.deploy_public_rds ? 1 : 0

  name        = "${terraform.workspace}-${local.project_name.name}-rds-credentials-be"
  description = "PostgreSQL credentials for ${terraform.workspace}"
  tags        = local.tags
}
resource "aws_secretsmanager_secret_version" "rds_credentials" {
  count = var.deploy_public_rds ? 1 : 0
  # secret_id = aws_secretsmanager_secret.rds_credentials[0].id
  secret_id = aws_secretsmanager_secret.rds_credentials[count.index].id


  secret_string = jsonencode({
    db_user     = aws_db_instance.postgres[0].username
    db_password = random_password.db_admin_password.result
    db_endpoint = aws_db_instance.postgres[0].endpoint
    db_name     = aws_db_instance.postgres[0].db_name
    db_engine   = "postgres"
    db_port     = 5432
  })
}


### File: public_sg.tf ###
# Security Group for RDS PostgreSQL Access
resource "aws_security_group" "rds" {
  count = var.deploy_public_rds ? 1 : 0

  name        = "${terraform.workspace}-rds-sg"
  description = "Restricted access to PostgreSQL"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}



### File: pvt_rds.tf ###
# RDS Subnet Group (Using Private Subnets)
resource "aws_db_subnet_group" "private_db" {
  count = var.deploy_private_rds ? 1 : 0

  name       = "${terraform.workspace}-${local.project_name.name}-lumifi-private-db-subnet-group"
  subnet_ids = terraform.workspace == "dev" ? aws_subnet.lumifi_subnets[*].id : data.aws_subnets.public[0].ids

  tags = merge(local.tags, {
    Name = "${terraform.workspace}-${local.project_name.name}-pvt-db-subnet-group"
  })
}

# Private PostgreSQL RDS Instance with KMS Encryption
resource "aws_db_instance" "postgres_private" {
  count = var.deploy_private_rds ? 1 : 0

  identifier        = "${terraform.workspace}-lumifi-db-private"
  allocated_storage = local.rds.allocated_storage
  storage_type      = "gp3"
  engine            = "postgres"
  engine_version    = "15"
  # Updated instance types per environment and Multi-AZ configuration
  # instance_class            = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.small"
  instance_class            = terraform.workspace == "prod" ? "db.t3.small" : "db.t3.small"
  multi_az                  = terraform.workspace == "prod" ? true : false
  db_name                   = "${terraform.workspace}_lumifi_private"
  username                  = "dbadmin"
  password                  = random_password.db_admin_password.result
  parameter_group_name      = "default.postgres15"
  skip_final_snapshot       = terraform.workspace == "dev" ? true : false
  final_snapshot_identifier = terraform.workspace == "prod" ? "${terraform.workspace}-lumifi-db-final-snapshot" : null
  # vpc_security_group_ids    = [aws_security_group.rds_private.id]
  # db_subnet_group_name      = aws_db_subnet_group.private_db.name
  vpc_security_group_ids = [aws_security_group.rds_private[0].id]
  db_subnet_group_name   = aws_db_subnet_group.private_db[0].name

  publicly_accessible = false
  apply_immediately   = true
  # Added KMS, backup, and deletion protection settings
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.lumifi_cmk.arn
  backup_retention_period = 7
  deletion_protection     = false
  tags                    = local.tags
  depends_on = [
    aws_nat_gateway.nat,
    aws_route_table.private_rt,
    aws_security_group.rds_private
  ]
}


### File: pvt_secrets.tf ###
# Secrets Manager - RDS Credentials
resource "aws_secretsmanager_secret" "rds_credentials_pvt" {
  count = var.deploy_private_rds ? 1 : 0

  name        = "${terraform.workspace}-${local.project_name.name}-rds-credentials-be-pvt"
  description = "PostgreSQL credentials for ${terraform.workspace}"
  tags        = local.tags
}
resource "aws_secretsmanager_secret_version" "rds_credentials_pvt" {
  count = var.deploy_private_rds ? 1 : 0
  # secret_id = aws_secretsmanager_secret.rds_credentials_pvt[0].id
  secret_id = aws_secretsmanager_secret.rds_credentials_pvt[count.index].id


  secret_string = jsonencode({
    db_user     = aws_db_instance.postgres_private[0].username
    db_password = random_password.db_admin_password.result
    db_endpoint = aws_db_instance.postgres_private[0].endpoint
    db_name     = aws_db_instance.postgres_private[0].db_name
    db_engine   = "postgres"
    db_port     = 5432
  })
}


### File: pvt_sg.tf ###
# Private RDS SG — allow only Lambda & Migration EC2.
# Lambda SG — allow outbound to RDS.
resource "aws_security_group" "lambda_sg_pvt" {
  count = var.deploy_private_rds ? 1 : 0

  name        = "${terraform.workspace}-lambda-pvt-sg"
  description = "Private Lambda access to private RDS"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.project_name.name}-lambda-pvt-sg-${terraform.workspace}"
  })
}

# RDS Private SG
resource "aws_security_group" "rds_private" {
  count = var.deploy_private_rds ? 1 : 0

  name   = "${terraform.workspace}-${local.project_name.name}-rds-pvt-sg"
  vpc_id = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg_pvt[0].id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}



### File: pvt_subnet.tf ###
# Private Subnets
resource "aws_subnet" "lumifi_private_subnets" {
  count = length(local.avail_zones)

  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id

  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index + 100)
  availability_zone       = local.avail_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.project_name.name}-private-subnet-${count.index + 1}"
    Tier = "private"
  }
}
# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = terraform.workspace == "dev" ? 1 : 0
  tags = {
    Name = "${local.project_name.name}-nat-eip"
  }
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
  count         = terraform.workspace == "dev" ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.lumifi_subnets[0].id # ✅ Should point to a public subnet
  tags = {
    Name = "${local.project_name.name}-nat-gateway"
  }
}
# Private Route Table
resource "aws_route_table" "private_rt" {
  count  = terraform.workspace == "dev" ? 1 : 0
  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = terraform.workspace == "dev" ? aws_nat_gateway.nat[0].id : data.aws_nat_gateway.existing[0].id
  }

  tags = {
    Name = "${local.project_name.name}-private-rt"
  }
}
# Associate private subnets
resource "aws_route_table_association" "private_assoc" {
  # count          = length(aws_subnet.lumifi_private_subnets)
  count          = length(local.avail_zones)
  subnet_id      = aws_subnet.lumifi_private_subnets[count.index].id
  route_table_id = terraform.workspace == "dev" ? aws_route_table.private_rt[0].id : data.aws_route_tables.private[0].ids[0]
}
output "lumifi_private_subnets" {
  value = aws_subnet.lumifi_private_subnets[*].id
}
# ------------------------------
# Data Source for Private Route Tables in Prod
# ------------------------------
data "aws_route_tables" "private" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

data "aws_subnets" "private" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}
# ------------------------------
# Data Source for Existing NAT Gateway (Prod)
# ------------------------------
data "aws_nat_gateway" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  # Optional: use tag if you named it
  # filter {
  #   name   = "tag:Name"
  #   values = ["${local.project_name.name}-nat-gateway-dev"]
  # }
}


### File: rds_password.tf ###
# Random Password for RDS Admin
resource "random_password" "db_admin_password" {
  length           = 16
  special          = true
  override_special = "!$%^&*()-_=+?"
}


### File: s3.tf ###
# S3 Bucket - Backend Data
resource "aws_s3_bucket" "backend" {
  bucket = "${local.project_name.name}-${terraform.workspace}-be-exports"
  tags   = local.tags
}
resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Disabled"
  }
}

# S3 Bucket - Logs Storage
resource "aws_s3_bucket" "logs" {
  bucket = "${local.project_name.name}-${terraform.workspace}-audit-log-backup"
  tags   = local.tags
}
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
# # Public Access Block for Logs Bucket (Restrict in Prod)  
# resource "aws_s3_bucket_public_access_block" "logs" {
#   bucket                  = aws_s3_bucket.logs.id
#   block_public_acls       = terraform.workspace == "prod" ? true : false
#   block_public_policy     = terraform.workspace == "prod" ? true : false
#   ignore_public_acls      = terraform.workspace == "prod" ? true : false
#   restrict_public_buckets = terraform.workspace == "prod" ? true : false

# }
# Always block public access (for all environments)
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
## Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "backend_sse" {
  bucket = aws_s3_bucket.backend.id


  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3 (AES-256) or use aws:kms for SSE-KMS
    }
  }
}


### File: security_group.tf ###

# Security Group for Lumifi Resources Access
resource "aws_security_group" "lumifi_sg" {
  name        = "${terraform.workspace}-${local.project_name.name}-sg"
  description = "Security group for lumifi instances"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


  dynamic "ingress" {
    for_each = [for rule in local.sg : rule if rule.type == "ingress"]
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = [for rule in local.sg : rule if rule.type == "egress"]
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${local.project_name.name}-sg-${terraform.workspace}"
  }
}
# Security Group for Lambda Function
resource "aws_security_group" "lambda_sg" {
  name        = "${terraform.workspace}-lambda-sg"
  description = "Lambda access to RDS and internet"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.project_name.name}-lambda-sg-${terraform.workspace}"
  })
}


### File: variables.tf ###
variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "deploy_public_rds" {
  description = "Whether to deploy public RDS (true for dev, false for prod)"
  type        = bool
  default     = false
}

variable "deploy_private_rds" {
  description = "Whether to deploy private RDS (false for dev, true for prod)"
  type        = bool
  default     = true
}


### File: vpc_endpoints.tf ###
# # VPC Endpoint for Amazon S3 (Gateway Type)
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id

#   service_name      = "com.amazonaws.${local.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].id : try(data.aws_route_tables.public.ids[0], null)
# }
# # VPC Endpoint for AWS Secrets Manager (Interface Type)
# resource "aws_vpc_endpoint" "secretsmanager" {
#   vpc_id              = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id

#   service_name        = "com.amazonaws.${local.aws_region}.secretsmanager"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = terraform.workspace == "dev" ? aws_subnet.lumifi_subnets[*].id : data.aws_subnets.public.ids
#   security_group_ids  = [aws_security_group.lambda_sg.id] # Use Lambda SG to allow Secrets Manager traffic
#   private_dns_enabled = true                              # Enable private DNS for internal resolution
# }


### File: vpc_subnet.tf ###
# VPC Configuration
resource "aws_vpc" "lumifi-vpc" {
  count = terraform.workspace == "dev" ? 1 : 0
  # Only create the VPC if it doesn't exist. You can import the existing VPC for dev.
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${local.project_name.name}-vpc"
  }
}

# Public Subnets Configuration (One per Availability Zone)
resource "aws_subnet" "lumifi_subnets" {
  count = length(local.avail_zones)

  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id

  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index + 1)
  availability_zone       = local.avail_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name.name}-subnet-${count.index + 1}"
    Tier = "public"
  }
}

# Internet Gateway for Public Access
resource "aws_internet_gateway" "lumifi-igw" {
  count  = terraform.workspace == "dev" ? 1 : 0
  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id

  tags = {
    Name = "${local.project_name.name}-IGW"
  }
}

# Public Route Table Configuration
resource "aws_route_table" "lumifi-pub-rt" {
  count  = terraform.workspace == "dev" ? 1 : 0
  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id

  depends_on = [aws_internet_gateway.lumifi-igw[0]]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = terraform.workspace == "dev" ? aws_internet_gateway.lumifi-igw[0].id : data.aws_internet_gateway.existing[0].id
  }

  tags = {
    Name = "${local.project_name.name}-MainRT"
  }
}

# Associate Route Table with All Public Subnets
resource "aws_route_table_association" "subnet_associations" {
  # count = length(aws_subnet.lumifi_subnets)
  count = length(local.avail_zones)

  subnet_id      = aws_subnet.lumifi_subnets[count.index].id
  route_table_id = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].id : try(data.aws_route_tables.public[0].ids[0], null)
}

# ------------------------------
# Data Sources for Existing Prod VPC
# ------------------------------
data "aws_vpc" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${local.project_name.name}-vpc"]
  }
}
data "aws_subnets" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
}
data "aws_subnets" "public" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}

# data "aws_internet_gateway" "existing" {
#   count = terraform.workspace == "prod" ? 1 : 0
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.existing[0].id]
#   }
# }

data "aws_route_tables" "public" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}
# ------------------------------
# Data Source for Existing Internet Gateway (Prod)
# ------------------------------
data "aws_internet_gateway" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0

  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }

  # Optional: if you named it during dev creation
  # filter {
  #   name   = "tag:Name"
  #   values = ["dev-lumifitest-IGW"]
  # }
}


