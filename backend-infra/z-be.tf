# ### File: api-lambdatest.tf ###
# resource "aws_apigatewayv2_api" "lambda1_api" {
#   name          = "${local.project_name.name}-${terraform.workspace}-api"
#   protocol_type = "HTTP"
#   tags          = merge(local.tags, local.project_name)
# }

# resource "aws_apigatewayv2_stage" "lambda1_api" {
#   api_id      = aws_apigatewayv2_api.lambda1_api.id
#   name        = "$default"
#   auto_deploy = true
# }

# resource "aws_apigatewayv2_integration" "lambda_test" {
#   api_id             = aws_apigatewayv2_api.lambda1_api.id
#   integration_type   = "AWS_PROXY"
#   integration_method = "POST"
#   integration_uri    = aws_lambda_function.test_function.invoke_arn
# }

# resource "aws_apigatewayv2_route" "test" {
#   api_id    = aws_apigatewayv2_api.lambda1_api.id
#   route_key = "GET /test"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda_test.id}"
# }

# resource "aws_lambda_permission" "api_gw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.test_function.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_apigatewayv2_api.lambda1_api.execution_arn}/*/*"
# }


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


# ### File: iam.tf ###
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


# ### File: lambda-test.tf ###
# data "archive_file" "lambda_test_zip" {
#   type        = "zip"
#   source_file = "${path.module}/lambda/test_function.py"
#   output_path = "${path.module}/lambda/test_function.zip"
# }

# resource "aws_lambda_function" "test_function" {
#   filename         = data.archive_file.lambda_test_zip.output_path
#   function_name    = "${local.project_name.name}-${terraform.workspace}-test"
#   role             = aws_iam_role.lambda_role.arn
#   handler          = "test_function.lambda_handler"
#   runtime          = "python3.12"
#   source_code_hash = data.archive_file.lambda_test_zip.output_base64sha256

#   tags = merge(local.tags, local.project_name)
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


# ### File: outputs.tf ###
# output "api_url" {
#   value = "${aws_apigatewayv2_api.lambda1_api.api_endpoint}/test"
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


