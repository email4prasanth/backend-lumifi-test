# Secrets Manager - RDS Credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${terraform.workspace}-${local.project_name.name}-rds_credentials-backend-v3"
  description = "PostgreSQL credentials for ${terraform.workspace}"
  tags        = local.tags
}
resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    db_user = aws_db_instance.postgres.username
    db_password = random_password.db_admin_password.result
    db_endpoint = aws_db_instance.postgres.endpoint
    db_name  = aws_db_instance.postgres.db_name
    db_engine   = "postgres"
    db_port     = 5432
  })
}