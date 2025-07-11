# ### File: api_gateway_serverless.tf ###

# # CloudWatch Log Group for Serverless API Gateway
# resource "aws_cloudwatch_log_group" "serverless_api_logs" {
#   name              = "/aws/api-gw/${aws_apigatewayv2_api.serverless_api.name}"
#   retention_in_days = 14
#   tags              = local.tags
# }


# # API Gateway for Serverless Service
# resource "aws_apigatewayv2_api" "serverless_api" {
#   name          = "${local.project_name.name}-${terraform.workspace}-serverless-api"
#   protocol_type = "HTTP"
#   tags          = local.tags
# }

# resource "aws_apigatewayv2_stage" "serverless_stage" {
#   api_id      = aws_apigatewayv2_api.serverless_api.id
#   name        = "$default"
#   auto_deploy = true

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.serverless_api_logs.arn
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
#   tags = local.tags
# }

# # API Gateway Integration
# resource "aws_apigatewayv2_integration" "serverless_integration" {
#   api_id = aws_apigatewayv2_api.serverless_api.id
#   # integration_type = "HTTP_PROXY"
#   integration_type = "AWS_PROXY"
#   integration_uri  = data.aws_lambda_function.serverless_lambda.invoke_arn # Point to your serverless Lambda
#   # integration_method     = "ANY"
#   payload_format_version = "1.0"
#   # payload_format_version = "2.0"
# }

# # API Gateway Routes
# resource "aws_apigatewayv2_route" "api_v1_route" {
#   api_id    = aws_apigatewayv2_api.serverless_api.id
#   route_key = "ANY /${local.api_root_path}/{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.serverless_integration.id}"
# }

# resource "aws_apigatewayv2_route" "root_route" {
#   api_id    = aws_apigatewayv2_api.serverless_api.id
#   route_key = "ANY /{proxy+}"
#   # route_key = "$default"
#   target = "integrations/${aws_apigatewayv2_integration.serverless_integration.id}"
# }

# resource "aws_apigatewayv2_route" "catchall_route" {
#   api_id    = aws_apigatewayv2_api.serverless_api.id
#   route_key = "$default"
#   target    = "integrations/${aws_apigatewayv2_integration.serverless_integration.id}"
# }


# ### File: api_gateway.tf ###
# # CloudWatch Log Group for API Gateway
# resource "aws_cloudwatch_log_group" "lambda1_api_logs" {
#   name              = "/aws/api-gw/${aws_apigatewayv2_api.lambda1_api.name}"
#   retention_in_days = 14
#   tags              = local.tags
# }

# # Keep only ONE copy of these resources:
# resource "aws_apigatewayv2_api" "lambda1_api" {
#   name          = "${local.project_name.name}-${terraform.workspace}-processor-api"
#   protocol_type = "HTTP"
# }

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

# resource "aws_apigatewayv2_route" "lambda1_test" {
#   api_id    = aws_apigatewayv2_api.lambda1_api.id
#   route_key = "ANY /test"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
# }

# resource "aws_apigatewayv2_route" "lambda1_test_slash" {
#   api_id    = aws_apigatewayv2_api.lambda1_api.id
#   route_key = "ANY /test/{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
# }

# resource "aws_apigatewayv2_integration" "lambda1_integration" {
#   api_id           = aws_apigatewayv2_api.lambda1_api.id
#   integration_type = "AWS_PROXY"
#   integration_uri  = module.lambda1.lambda_function_invoke_arn
# }




# ### File: backend.tf ###
# # Terraform Remote Backend Configuration - S3 for backend code 
# terraform {
#   backend "s3" {
#     bucket  = "lumifitfstore"
#     key     = "backend/terraform.tfstate"
#     region  = "us-east-1"
#     # profile = "lumifitest"
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


# ### File: lambda1.tf ###
# module "lambda1" {
#   source = "../services/lambda-1"

#   # Pass required variables
#   subnet_ids                = aws_subnet.lumifi_subnets[*].id
#   lambda_sg_id              = aws_security_group.lambda_sg.id
#   lambda_role_arn           = aws_iam_role.lambda_role.arn
#   backend_bucket            = aws_s3_bucket.backend.bucket
#   api_gateway_id            = aws_apigatewayv2_api.lambda1_api.id
#   api_gateway_execution_arn = aws_apigatewayv2_api.lambda1_api.execution_arn
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

#   # ses_config = {
#   #   "dev"  = { email_limit = 10000 }
#   #   "prod" = { email_limit = 25000 }
#   # }
#   # glacier_config = {
#   #   "dev"  = { storage_gb = 10, requests = 1000 }
#   #   "prod" = { storage_gb = 100, requests = 10000 }
#   # }
#   sender_email   = "reachtechprasanth@gmail.com"
#   receiver_email = "marriprasanth.p@hubino.com"

#   api_root_path = "api/v1"
# }


# ### File: output.tf ###
# # outputs.tf
# output "smtp_credentials" {
#   value = {
#     username = aws_iam_access_key.smtp_user.id
#     password = aws_iam_access_key.smtp_user.ses_smtp_password_v4
#   }
#   sensitive = true
# }

# output "verified_emails" {
#   value = {
#     sender    = aws_ses_email_identity.sender.email
#     recipient = aws_ses_email_identity.recipient.email
#   }
# }

# output "api_endpoint" {
#   value = aws_apigatewayv2_api.lambda1_api.api_endpoint
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
#   # profile = "lumifitest"
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


# ### File: serverlessLambda.tf ###
# data "aws_lambda_function" "serverless_lambda" {
#   function_name = "${terraform.workspace}-serverless-lambda" # Match your serverless deploy name
# }

# resource "aws_lambda_permission" "serverless_apigw" {
#   statement_id  = "AllowServerlessAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = data.aws_lambda_function.serverless_lambda.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_apigatewayv2_api.serverless_api.execution_arn}/*/*"
# }


# ### File: ses.tf ###
# # ses.tf
# resource "aws_ses_email_identity" "sender" {
#   email = local.sender_email
# }

# resource "aws_ses_email_identity" "recipient" {
#   email = local.receiver_email
# }

# resource "aws_ses_configuration_set" "sandbox" {
#   name = "${local.project_name.name}-${terraform.workspace}-ses-sandbox-config"
# }

# resource "aws_iam_user" "smtp_user" {
#   name = "${local.project_name.name}-${terraform.workspace}-ses-smtp-user"
# }

# resource "aws_iam_access_key" "smtp_user" {
#   user = aws_iam_user.smtp_user.name
# }

# resource "aws_iam_user_policy" "smtp_send" {
#   name = "${local.project_name.name}-${terraform.workspace}-ses-send-policy"
#   user = aws_iam_user.smtp_user.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = "ses:SendRawEmail"
#       Resource = "*"
#     }]
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


