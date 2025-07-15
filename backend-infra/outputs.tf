# outputs.tf (in Terraform)
output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "subnet_ids" {
  value = aws_subnet.lumifi_subnets[*].id
}

# Example Terraform outputs
output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

resource "aws_secretsmanager_secret" "backend_secrets" {
  name = "lumifi-backend/${terraform.workspace}-secrets"
}

resource "aws_secretsmanager_secret_version" "backend_secrets" {
  secret_id = aws_secretsmanager_secret.backend_secrets.id
  secret_string = jsonencode({
    db_name     = aws_db_instance.main.name
    db_user     = aws_db_instance.main.username
    db_password = aws_db_instance.main.password
    db_port     = aws_db_instance.main.port
  })
}