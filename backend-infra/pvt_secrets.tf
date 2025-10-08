# Secrets Manager - RDS Credentials
resource "aws_secretsmanager_secret" "rds_credentials_pvt" {
  count = var.deploy_private_rds ? 1 : 0

  name        = "${terraform.workspace}-${local.project_name.name}-rds-credentials-be-pvt"
  description = "PostgreSQL credentials for ${terraform.workspace}"
  tags        = local.tags
}
resource "aws_secretsmanager_secret_version" "rds_credentials_pvt" {
  count = var.deploy_private_rds ? 1 : 0
  # secret_id = aws_secretsmanager_secret.rds_credentials_pvt[0].id
  secret_id = aws_secretsmanager_secret.rds_credentials_pvt[count.index].id


  secret_string = jsonencode({
    db_user     = aws_db_instance.postgres_private[0].username
    db_password = random_password.db_admin_password.result
    db_endpoint = aws_db_instance.postgres_private[0].endpoint
    db_name     = aws_db_instance.postgres_private[0].db_name
    db_engine   = "postgres"
    db_port     = 5432
  })
}
