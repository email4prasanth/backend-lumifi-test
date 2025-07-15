# outputs.tf (in Terraform)
output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "subnet_ids" {
  value = aws_subnet.lumifi_subnets[*].id
}

# Example Terraform outputs
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

resource "aws_secretsmanager_secret" "backend_secrets" {
  name = "lumifi-backend/${terraform.workspace}-secrets"
}

resource "aws_secretsmanager_secret_version" "backend_secrets" {
  secret_id = aws_secretsmanager_secret.backend_secrets.id
  secret_string = jsonencode({
    db_name     = aws_db_instance.postgres.db_name
    db_user     = aws_db_instance.postgres.username
    db_password = random_password.db_admin_password.result
    db_port     = 5432
    db_endpoint = aws_db_instance.postgres.endpoint
  })
}