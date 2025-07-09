locals {
  aws_region = "us-east-1"
  # Tags, VPC CIDR, Availability Zones Configuration for Dev and Prod Environment
  tags = {
    owner       = "lumifi"
    environment = terraform.workspace
  }
  project_name = {
    name = "lumifi"
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

  ses_config = {
    "dev"  = { email_limit = 10000 }
    "prod" = { email_limit = 25000 }
  }
  glacier_config = {
    "dev"  = { storage_gb = 10, requests = 1000 }
    "prod" = { storage_gb = 100, requests = 10000 }
  }
  sender_email   = "reachtechprasanth@gmail.com"
  receiver_email = "marriprasanth.p@hubino.com"
}
