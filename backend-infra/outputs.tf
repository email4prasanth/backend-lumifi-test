# outputs.tf (in Terraform)
output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "subnet_ids" {
  value = join(",", aws_subnet.lumifi_subnets[*].id)
}

# # Example Terraform outputs
# output "rds_endpoint" {
#   value = aws_db_instance.postgres.endpoint
# }

# Conditional RDS endpoint output
output "rds_endpoint" {
  description = "RDS endpoint based on environment"
  value = var.deploy_public_rds ? (
    aws_db_instance.postgres[0].endpoint
    ) : (
    var.deploy_private_rds ? aws_db_instance.postgres_private[0].endpoint : null
  )
}

output "rds_type" {
  description = "Type of RDS deployed"
  value = var.deploy_public_rds ? "public" : (
    var.deploy_private_rds ? "private" : "none"
  )
}
