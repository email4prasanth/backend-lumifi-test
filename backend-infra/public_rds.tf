
# RDS Subnet Group (Using Public Subnets)
resource "aws_db_subnet_group" "public_db" {
  count = var.deploy_public_rds ? 1 : 0

  name       = "${terraform.workspace}-lumifi-public-db-subnet-group"
  subnet_ids = terraform.workspace == "dev" ? aws_subnet.lumifi_subnets[*].id : data.aws_subnets.public[0].ids

  tags = merge(local.tags, {
    Name = "${terraform.workspace}-db-subnet-group"
  })
}

# PostgreSQL RDS Instance with KMS Encryption
resource "aws_db_instance" "postgres" {
  count = var.deploy_public_rds ? 1 : 0

  identifier        = "${terraform.workspace}-lumifi-db"
  allocated_storage = local.rds.allocated_storage
  storage_type      = "gp3"
  engine            = "postgres"
  engine_version    = "15"
  # Updated instance types per environment and Multi-AZ configuration
  #   instance_class            = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.small"
  instance_class            = terraform.workspace == "prod" ? "db.t3.small" : "db.t3.small"
  multi_az                  = terraform.workspace == "prod" ? true : false
  db_name                   = "${terraform.workspace}_lumifi"
  username                  = "dbadmin"
  password                  = random_password.db_admin_password.result
  parameter_group_name      = "default.postgres15"
  skip_final_snapshot       = terraform.workspace == "dev" ? true : false
  final_snapshot_identifier = terraform.workspace == "prod" ? "${terraform.workspace}-lumifi-db-final-snapshot" : null
  # vpc_security_group_ids    = [aws_security_group.rds.id]
  # db_subnet_group_name      = aws_db_subnet_group.public_db.name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  db_subnet_group_name   = aws_db_subnet_group.public_db[0].name
  publicly_accessible    = true
  apply_immediately      = true
  # Added KMS, backup, and deletion protection settings
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.lumifi_cmk.arn
  backup_retention_period = 7
  deletion_protection     = false
  tags                    = local.tags
  depends_on = [
    aws_internet_gateway.lumifi-igw[0],
    aws_route_table.lumifi-pub-rt,
    aws_security_group.lumifi_sg
  ]
}


# # PostgreSQL RDS Instance
# resource "aws_db_instance" "postgres" {
#   identifier        = "${terraform.workspace}-lumifi-db"
#   allocated_storage = local.rds.allocated_storage
#   storage_type      = "gp3"
#   engine            = "postgres"
#   engine_version    = "15"
#   # Updated instance types per environment
#   # instance_class = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.small"
#   instance_class = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.micro" # For testing
#   # Multi-AZ configuration
#   multi_az               = terraform.workspace == "prod" ? true : false
#   db_name                = "${terraform.workspace}_lumifi"
#   username               = "dbadmin"
#   password               = random_password.db_admin_password.result
#   # parameter_group_name   = "default.postgres15"
#   parameter_group_name   = aws_db_parameter_group.lumifi_pg.name
#   skip_final_snapshot    = terraform.workspace == "dev" ? true : false
#   vpc_security_group_ids = [aws_security_group.rds.id]
#   db_subnet_group_name   = aws_db_subnet_group.public_db.name
#   publicly_accessible    = true
#   apply_immediately      = true
#   tags                   = local.tags
#   depends_on = [
#     aws_internet_gateway.lumifi-igw[0],
#     aws_route_table.lumifi-pub-rt,
#     aws_security_group.lumifi_sg
#   ]
# }