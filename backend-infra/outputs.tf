# outputs.tf (in Terraform)
output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "subnet_ids" {
  value = join(",", aws_subnet.lumifi_subnets[*].id)
}

# Example Terraform outputs
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

