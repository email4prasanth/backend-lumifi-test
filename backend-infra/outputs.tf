# outputs.tf (in Terraform)
output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "subnet_ids" {
  value = join(",", terraform.workspace == "prod" ? data.aws_subnets.existing.ids : aws_subnet.lumifi_subnets[*].id)
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
# 🌐 VPC & Subnets
# ------------------------------
output "vpc_name" {
  description = "Name of the Lumifi VPC"
  value       = aws_vpc.lumifi-vpc.tags["Name"]
}

output "vpc_id" {
  description = "ID of the Lumifi VPC"
  value       = terraform.workspace == "prod" ? data.aws_vpc.existing.id : aws_vpc.lumifi-vpc.id
}

output "public_subnet_names" {
  description = "Names of the public subnets"
  value       = [for s in aws_subnet.lumifi_subnets : s.tags["Name"]]
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = terraform.workspace == "prod" ? data.aws_subnets.existing.ids : aws_subnet.lumifi_subnets[*].id
}

output "private_subnet_names" {
  description = "Names of the private subnets"
  value       = [for s in aws_subnet.lumifi_private_subnets : s.tags["Name"]]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.lumifi_private_subnets[*].id
}

# ------------------------------
# 🧱 Route Tables, Gateways
# ------------------------------
output "internet_gateway_name" {
  description = "Name of the Internet Gateway"
  value       = aws_internet_gateway.lumifi-igw.tags["Name"]
}

output "public_route_table_name" {
  description = "Name of the Public Route Table"
  value       = aws_route_table.lumifi-pub-rt.tags["Name"]
}

output "private_route_table_name" {
  description = "Name of the Private Route Table"
  value       = aws_route_table.private_rt.tags["Name"]
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
