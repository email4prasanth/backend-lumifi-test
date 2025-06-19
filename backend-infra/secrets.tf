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