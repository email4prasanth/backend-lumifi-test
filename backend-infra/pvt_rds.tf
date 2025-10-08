# RDS Subnet Group (Using Private Subnets)
resource "aws_db_subnet_group" "private_db" {
  count = var.deploy_private_rds ? 1 : 0

  name       = "${terraform.workspace}-${local.project_name.name}-lumifi-private-db-subnet-group"
  subnet_ids = aws_subnet.lumifi_private_subnets[*].id

  tags = merge(local.tags, {
    Name = "${terraform.workspace}-${local.project_name.name}-pvt-db-subnet-group"
  })
}

# Private PostgreSQL RDS Instance with KMS Encryption
resource "aws_db_instance" "postgres_private" {
  count = var.deploy_private_rds ? 1 : 0

  identifier        = "${terraform.workspace}-lumifi-db-private"
  allocated_storage = local.rds.allocated_storage
  storage_type      = "gp3"
  engine            = "postgres"
  engine_version    = "15"
  # Updated instance types per environment and Multi-AZ configuration
  # instance_class            = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.small"
  instance_class            = terraform.workspace == "prod" ? "db.t3.small" : "db.t3.small"
  multi_az                  = terraform.workspace == "prod" ? true : false
  db_name                   = "${terraform.workspace}_lumifi_private"
  username                  = "dbadmin"
  password                  = random_password.db_admin_password.result
  parameter_group_name      = "default.postgres15"
  skip_final_snapshot       = terraform.workspace == "dev" ? true : false
  final_snapshot_identifier = terraform.workspace == "prod" ? "${terraform.workspace}-lumifi-db-final-snapshot" : null
  # vpc_security_group_ids    = [aws_security_group.rds_private.id]
  # db_subnet_group_name      = aws_db_subnet_group.private_db.name
  vpc_security_group_ids = [aws_security_group.rds_private[0].id]
  db_subnet_group_name   = aws_db_subnet_group.private_db[0].name

  publicly_accessible = false
  apply_immediately   = true
  # Added KMS, backup, and deletion protection settings
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.lumifi_cmk.arn
  backup_retention_period = 7
  deletion_protection     = false
  tags                    = local.tags
  depends_on = [
    aws_nat_gateway.nat,
    aws_route_table.private_rt,
    aws_security_group.rds_private
  ]
}
