# ### File: acm.tf ###
# # API Gateway Certificate
# resource "aws_acm_certificate" "api_cert" {
#   domain_name       = "api.aitechlearn.xyz"
#   validation_method = "DNS"
# }

# # DNS Validation for API Certificate
# resource "aws_route53_record" "api_cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.domain.zone_id
# }

# # Certificate Validation for API
# resource "aws_acm_certificate_validation" "api_cert" {
#   certificate_arn         = aws_acm_certificate.api_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.api_cert_validation : record.fqdn]
# }


# ### File: api_gateway.tf ###
# # API Gateway Custom Domain
# resource "aws_apigatewayv2_domain_name" "api" {
#   domain_name = "api.aitechlearn.xyz"
#   depends_on  = [aws_acm_certificate_validation.api_cert]

#   domain_name_configuration {
#     certificate_arn = aws_acm_certificate.api_cert.arn
#     endpoint_type   = "REGIONAL"
#     security_policy = "TLS_1_2"
#   }
# }

# # # API Gateway mapping for Lambda1
# # resource "aws_apigatewayv2_api_mapping" "lambda1" {
# #   api_id      = aws_apigatewayv2_api.lambda1_api.id
# #   domain_name = aws_apigatewayv2_domain_name.api.id
# #   stage       = aws_apigatewayv2_stage.lambda1_stage.id
# # }


# ### File: backend.tf ###
# # Terraform Remote Backend Configuration - S3 for backend code
# terraform {
#   backend "s3" {
#     bucket  = "lumifitfstore"
#     key     = "backend/terraform.tfstate"
#     region  = "us-east-1"
#     profile = "lumifitest"
#   }
# }


# ### File: locals.tf ###
# locals {
#   aws_region = "us-east-1"
#   # Tags, VPC CIDR, Availability Zones Configuration for Dev and Prod Environment
#   tags = {
#     owner       = "lumifi"
#     environment = terraform.workspace
#   }
#   project_name = {
#     name = "lumifi"
#   }
#   cidr_ranges = {
#     "dev"  = "10.60.0.0/16"
#     "prod" = "10.61.0.0/16"
#   }
#   vpc_cidr = lookup(local.cidr_ranges, terraform.workspace, "10.60.0.0/16")
#   az = {
#     "dev"  = ["us-east-1a", "us-east-1b"] # Two AZs but deploy RDS in single AZ for DEV
#     "prod" = ["us-east-1a", "us-east-1b"] # Two AZs with Multi-AZ deployment for PROD
#   }
#   avail_zones = lookup(local.az, terraform.workspace, ["us-east-1a"])

#   # Security Group Rules for Dev and Prod Environment
#   security_group_rules = {
#     "dev" = [
#       {
#         type        = "ingress"
#         description = "Allow SSH inbound traffic"
#         from_port   = 22
#         to_port     = 22
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#       },
#       {
#         type        = "ingress"
#         description = "Allow HTTP inbound traffic"
#         from_port   = 80
#         to_port     = 80
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#       },
#       {
#         type        = "ingress"
#         description = "Allow HTTPS inbound traffic"
#         from_port   = 443
#         to_port     = 443
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#       },
#       {
#         type        = "egress"
#         description = "Allow all outbound traffic"
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#       }
#     ]
#     "prod" = [
#       {
#         type        = "ingress"
#         description = "Allow SSH inbound traffic"
#         from_port   = 22
#         to_port     = 22
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#       },
#       {
#         type        = "ingress"
#         description = "Allow HTTP inbound traffic"
#         from_port   = 80
#         to_port     = 80
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#       },
#       {
#         type        = "ingress"
#         description = "Allow HTTPS inbound traffic"
#         from_port   = 443
#         to_port     = 443
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#       },
#       {
#         type        = "egress"
#         description = "Allow all outbound traffic"
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#       }
#     ]
#   }
#   sg = lookup(local.security_group_rules, terraform.workspace, local.security_group_rules["dev"])

#   # RDS Configuration for Dev and Prod Environment
#   db_config = {
#     "dev" = {
#       allocated_storage = 20
#     }
#     "prod" = {
#       allocated_storage = 100
#     }
#   }
#   rds = lookup(local.db_config, terraform.workspace, local.db_config["dev"])

#   ses_config = {
#     "dev"  = { email_limit = 10000 }
#     "prod" = { email_limit = 25000 }
#   }
#   glacier_config = {
#     "dev"  = { storage_gb = 10, requests = 1000 }
#     "prod" = { storage_gb = 100, requests = 10000 }
#   }

# }


# ### File: providers.tf ###
# # Terraform Block with Required Providers
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }
# # AWS Provider Configuration
# provider "aws" {
#   region  = local.aws_region
#   profile = "lumifitest"
# }



# ### File: route53.tf ###
# # Route 53 Hosted Zone Lookup
# data "aws_route53_zone" "domain" {
#   name         = "aitechlearn.xyz."
#   private_zone = false
# }

# # API Gateway Custom Domain Alias Record
# resource "aws_route53_record" "api_gateway" {
#   zone_id = data.aws_route53_zone.domain.zone_id
#   name    = "api.aitechlearn.xyz"
#   type    = "A"

#   alias {
#     name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
#     zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
#     evaluate_target_health = false
#   }
# }


# ### File: s3.tf ###
# # S3 Bucket - Backend Data
# resource "aws_s3_bucket" "backend" {
#   bucket = "${local.project_name.name}-${terraform.workspace}-backend-test"
#   tags   = local.tags
# }
# resource "aws_s3_bucket_versioning" "backend" {
#   bucket = aws_s3_bucket.backend.id
#   versioning_configuration {
#     status = "Disabled"
#   }
# }

# # S3 Bucket - Logs Storage
# resource "aws_s3_bucket" "logs" {
#   bucket = "${local.project_name.name}-${terraform.workspace}-logs-test"
#   tags   = local.tags
# }
# resource "aws_s3_bucket_ownership_controls" "logs" {
#   bucket = aws_s3_bucket.logs.id
#   rule {
#     object_ownership = "BucketOwnerEnforced"
#   }
# }
# resource "aws_s3_bucket_public_access_block" "logs" {
#   bucket = aws_s3_bucket.logs.id
#   # block_public_acls       = false
#   # block_public_policy     = false
#   # ignore_public_acls      = false
#   # restrict_public_buckets = false
#   block_public_acls       = terraform.workspace == "prod" ? true : false
#   block_public_policy     = terraform.workspace == "prod" ? true : false
#   ignore_public_acls      = terraform.workspace == "prod" ? true : false
#   restrict_public_buckets = terraform.workspace == "prod" ? true : false

# }


# ### File: security_groups.tf ###
# # Security Group for Lumifi Resources Access
# resource "aws_security_group" "lumifi_sg" {
#   name        = "${terraform.workspace}-${local.project_name.name}-sg"
#   description = "Security group for lumifi instances"
#   vpc_id      = aws_vpc.lumifi-vpc.id

#   dynamic "ingress" {
#     for_each = [for rule in local.sg : rule if rule.type == "ingress"]
#     content {
#       description = ingress.value.description
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#     }
#   }

#   dynamic "egress" {
#     for_each = [for rule in local.sg : rule if rule.type == "egress"]
#     content {
#       description = egress.value.description
#       from_port   = egress.value.from_port
#       to_port     = egress.value.to_port
#       protocol    = egress.value.protocol
#       cidr_blocks = egress.value.cidr_blocks
#     }
#   }

#   tags = {
#     Name = "${local.project_name.name}-sg-${terraform.workspace}"
#   }
# }

# # Security Group for RDS PostgreSQL Access
# resource "aws_security_group" "rds" {
#   name        = "${terraform.workspace}-rds-sg"
#   description = "Restricted access to PostgreSQL"
#   vpc_id      = aws_vpc.lumifi-vpc.id

#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     cidr_blocks     = ["0.0.0.0/0"]
#     security_groups = [aws_security_group.lambda_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = local.tags
# }

# # Security Group for Lambda Function
# resource "aws_security_group" "lambda_sg" {
#   name        = "${terraform.workspace}-lambda-sg"
#   description = "Lambda access to RDS and internet"
#   vpc_id      = aws_vpc.lumifi-vpc.id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(local.tags, {
#     Name = "${local.project_name.name}-lambda-sg-${terraform.workspace}"
#   })
# }


# ### File: vpc_subnet.tf ###
# # VPC Configuration
# resource "aws_vpc" "lumifi-vpc" {
#   cidr_block           = local.vpc_cidr
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   tags = {
#     Name = "${terraform.workspace}-${local.project_name.name}-vpc"
#   }
# }

# # Public Subnets Configuration (One per Availability Zone)
# resource "aws_subnet" "lumifi_subnets" {
#   count = length(local.avail_zones)

#   vpc_id                  = aws_vpc.lumifi-vpc.id
#   cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index + 1)
#   availability_zone       = local.avail_zones[count.index]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "${terraform.workspace}-${local.project_name.name}-subnet-${count.index + 1}"
#     Tier = "public"
#   }
# }

# # Internet Gateway for Public Access
# resource "aws_internet_gateway" "lumifi-igw" {
#   vpc_id = aws_vpc.lumifi-vpc.id
#   tags = {
#     Name = "${terraform.workspace}-${local.project_name.name}-IGW"
#   }
# }

# # Public Route Table Configuration
# resource "aws_route_table" "lumifi-pub-rt" {
#   vpc_id     = aws_vpc.lumifi-vpc.id
#   depends_on = [aws_internet_gateway.lumifi-igw]

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.lumifi-igw.id
#   }

#   tags = {
#     Name = "${terraform.workspace}-${local.project_name.name}-MainRT"
#   }
# }

# # Associate Route Table with All Public Subnets
# resource "aws_route_table_association" "subnet_associations" {
#   count = length(aws_subnet.lumifi_subnets)

#   subnet_id      = aws_subnet.lumifi_subnets[count.index].id
#   route_table_id = aws_route_table.lumifi-pub-rt.id
# }


