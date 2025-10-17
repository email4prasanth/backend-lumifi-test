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
  # value = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].id : try(data.aws_route_tables.public[0].ids[0], null)
  value = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].id : data.aws_route_tables.public[0].ids[0]
}

output "public_route_table_name" {
  value = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].tags["Name"] : try("lumifitest-MainRT", null)
  # value = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].tags["Name"] : try(data.aws_route_tables.public[0].tags[0]["Name"], null)
  # value = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].tags["Name"] : data.aws_route_tables.public[0].tags["Name"]
}

# ------------------------------
# Private Subnets Outputs
# ------------------------------
output "private_subnet_ids" {
  value = terraform.workspace == "dev" ? aws_subnet.lumifi_private_subnets[*].id : data.aws_subnets.private.ids
}

output "private_subnet_names" {
  value = terraform.workspace == "dev" ? [for s in aws_subnet.lumifi_private_subnets : s.tags["Name"]] : [for s in data.aws_subnets.private.ids : s]
}

output "private_route_table_id" {
  # value = terraform.workspace == "dev" ? aws_route_table.private_rt[0].id : try(data.aws_route_tables.private[0].ids[0], null)
  value = terraform.workspace == "dev" ? aws_route_table.private_rt[0].id : data.aws_route_tables.private[0].ids[0]
}

output "private_route_table_name" {
  value = terraform.workspace == "dev" ? aws_route_table.private_rt[0].tags["Name"] : try("lumifitest-private-rt", null)
  # value = terraform.workspace == "dev" ? aws_route_table.private_rt[0].tags["Name"] : try(data.aws_route_tables.private[0].tags[0]["Name"], null)
  # value = terraform.workspace == "dev" ? aws_route_table.private_rt[0].tags["Name"] : data.aws_route_tables.private[0].tags["Name"]
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
  value       = var.deploy_public_rds ? aws_security_group.rds_public[0].name : null
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
