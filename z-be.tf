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

# # API Gateway mapping for Lambda1
# resource "aws_apigatewayv2_api_mapping" "lambda1" {
#   api_id      = aws_apigatewayv2_api.lambda1_api.id
#   domain_name = aws_apigatewayv2_domain_name.api.id
#   stage       = aws_apigatewayv2_stage.lambda1_stage.id
# }


# ### File: backend.tf ###
# terraform {
#   backend "s3" {
#     bucket  = "lumifitfstore"
#     key     = "backend/terraform.tfstate"
#     region  = "us-east-1"
#     profile = "lumifitest"
#   }
# }


# ### File: iam.tf ###
# # IAM Role for Lambda Execution
# resource "aws_iam_role" "lambda_role" {
#   name = "${local.project_name.name}-${terraform.workspace}-lambda-exec-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
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

# # Custom IAM Policy for S3, RDS, Secrets Manager Access
# resource "aws_iam_policy" "lambda_s3_rds_access" {
#   name        = "${local.project_name.name}-${terraform.workspace}-lambda-s3-rds"
#   description = "Access to S3 buckets and RDS"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = ["s3:*", "ec2:*"]
#         Effect = "Allow"
#         Resource = [
#           aws_s3_bucket.backend.arn,
#           "${aws_s3_bucket.backend.arn}/*"
#         ]
#       },
#       {
#         Action   = "secretsmanager:GetSecretValue"
#         Effect   = "Allow"
#         Resource = aws_secretsmanager_secret.rds_credentials.arn
#       },
#       {
#         Action   = "rds-db:connect"
#         Effect   = "Allow"
#         Resource = "arn:aws:rds-db:${local.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.postgres.resource_id}/dbadmin"
#       }
#     ]
#   })
# }
# resource "aws_iam_role_policy_attachment" "lambda_s3_rds" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_s3_rds_access.arn
# }

# # Data Source: AWS Caller Identity
# data "aws_caller_identity" "current" {}

# # Custom IAM Policy for API Gateway Logging
# resource "aws_iam_policy" "api_gateway_logging" {
#   name        = "${local.project_name.name}-${terraform.workspace}-api-gw-logging"
#   description = "Permissions for API Gateway to write logs"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action   = ["logs:*"]
#       Effect   = "Allow"
#       Resource = "*"
#     }]
#   })
# }
# resource "aws_iam_role_policy_attachment" "api_gw_logging" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.api_gateway_logging.arn
# }


# ### File: lambda-1.tf ###
# # Lambda Function: Data Processor
# resource "aws_lambda_function" "data_processor" {
#   function_name = "${local.project_name.name}-${terraform.workspace}-processor"
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "index.handler"
#   runtime       = "nodejs18.x"
#   filename      = "lambda-1.zip"

#   vpc_config {
#     subnet_ids         = aws_subnet.lumifi_subnets[*].id
#     security_group_ids = [aws_security_group.lambda_sg.id]
#   }

#   environment {
#     variables = {
#       S3_BUCKET    = aws_s3_bucket.backend.bucket
#       ENVIRONMENT  = terraform.workspace
#       SERVICE_NAME = "data-processor"
#     }
#   }

#   tags = local.tags
# }

# # API Gateway v2 (HTTP API)
# resource "aws_apigatewayv2_api" "lambda1_api" {
#   name          = "${local.project_name.name}-${terraform.workspace}-processor-api"
#   protocol_type = "HTTP"
# }

# # API Gateway Stage
# resource "aws_apigatewayv2_stage" "lambda1_stage" {
#   api_id      = aws_apigatewayv2_api.lambda1_api.id
#   name        = "$default"
#   auto_deploy = true

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.lambda1_api_logs.arn
#     format = jsonencode({
#       requestId      = "$context.requestId"
#       ip             = "$context.identity.sourceIp"
#       requestTime    = "$context.requestTime"
#       httpMethod     = "$context.httpMethod"
#       routeKey       = "$context.routeKey"
#       status         = "$context.status"
#       responseLength = "$context.responseLength"
#     })
#   }
# }

# # API Gateway Integration with Lambda
# resource "aws_apigatewayv2_integration" "lambda1_integration" {
#   api_id           = aws_apigatewayv2_api.lambda1_api.id
#   integration_type = "AWS_PROXY"
#   integration_uri  = aws_lambda_function.data_processor.invoke_arn
# }

# # API Gateway Routes
# resource "aws_apigatewayv2_route" "lambda1_route" {
#   api_id    = aws_apigatewayv2_api.lambda1_api.id
#   route_key = "ANY /{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
# }
# resource "aws_apigatewayv2_route" "lambda1_root" {
#   api_id    = aws_apigatewayv2_api.lambda1_api.id
#   route_key = "GET /"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
# }

# # Lambda Permission for API Gateway
# resource "aws_lambda_permission" "lambda1_apigw" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.data_processor.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_apigatewayv2_api.lambda1_api.execution_arn}/*/*"
# }

# # CloudWatch Log Groups for Lambda & API Gateway
# resource "aws_cloudwatch_log_group" "lambda1_logs" {
#   name              = "/aws/lambda/${aws_lambda_function.data_processor.function_name}"
#   retention_in_days = 14
#   tags              = local.tags
# }
# resource "aws_cloudwatch_log_group" "lambda1_api_logs" {
#   name              = "/aws/api-gw/${aws_apigatewayv2_api.lambda1_api.name}"
#   retention_in_days = 14
#   tags              = local.tags
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
#   region  = "us-east-1"
#   profile = "lumifitest"
# }



# ### File: rds.tf ###
# # Random Password for RDS Admin
# resource "random_password" "db_admin_password" {
#   length           = 16
#   special          = true
#   override_special = "!$%^&*()-_=+?"
# }
# # RDS Subnet Group (Using Public Subnets)
# resource "aws_db_subnet_group" "public_db" {
#   name       = "${terraform.workspace}-lumifi-public-db-subnet-group"
#   subnet_ids = aws_subnet.lumifi_subnets[*].id

#   tags = merge(local.tags, {
#     Name = "${terraform.workspace}-db-subnet-group"
#   })
# }

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
#   parameter_group_name   = "default.postgres15"
#   skip_final_snapshot    = terraform.workspace == "dev" ? true : false
#   vpc_security_group_ids = [aws_security_group.rds.id]
#   db_subnet_group_name   = aws_db_subnet_group.public_db.name
#   publicly_accessible    = true
#   apply_immediately      = true
#   tags                   = local.tags
#   depends_on = [
#     aws_internet_gateway.lumifi-igw,
#     aws_route_table.lumifi-pub-rt,
#     aws_security_group.lumifi_sg
#   ]
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
#   bucket = "${local.project_name.name}-${terraform.workspace}-backend"
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
#   bucket = "${local.project_name.name}-${terraform.workspace}-logs"
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


# ### File: secrets.tf ###
# # Secrets Manager - RDS Credentials
# resource "aws_secretsmanager_secret" "rds_credentials" {
#   name        = "${terraform.workspace}-${local.project_name.name}-rds_credentials-backend-v1"
#   description = "PostgreSQL credentials for ${terraform.workspace}"
#   tags        = local.tags
# }
# resource "aws_secretsmanager_secret_version" "rds_credentials" {
#   secret_id = aws_secretsmanager_secret.rds_credentials.id
#   secret_string = jsonencode({
#     username = aws_db_instance.postgres.username
#     password = random_password.db_admin_password.result
#     endpoint = aws_db_instance.postgres.endpoint
#     db_name  = aws_db_instance.postgres.db_name
#     engine   = "postgres"
#     port     = 5432
#   })
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


# ### File: vpc_endpoints.tf ###
# # VPC Endpoint for Amazon S3 (Gateway Type)
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.lumifi-vpc.id
#   service_name      = "com.amazonaws.${local.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = [aws_route_table.lumifi-pub-rt.id]
# }
# # VPC Endpoint for AWS Secrets Manager (Interface Type)
# resource "aws_vpc_endpoint" "secretsmanager" {
#   vpc_id              = aws_vpc.lumifi-vpc.id
#   service_name        = "com.amazonaws.${local.aws_region}.secretsmanager"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.lumifi_subnets[*].id   # Attach endpoint to subnets
#   security_group_ids  = [aws_security_group.lambda_sg.id] # Use Lambda SG to allow Secrets Manager traffic
#   private_dns_enabled = true                              # Enable private DNS for internal resolution
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


