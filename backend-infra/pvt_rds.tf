# Get the correct VPC dynamically
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${local.project_name.name}-vpc"]
  }
}
# Get private subnets dynamically (avoid hardcoding)
data "aws_subnets" "private" {
  # count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"] # will match lumifitest-private-subnet-1/2
  }
}
# data "aws_subnets" "private" {
#   count = terraform.workspace == "prod" ? 1 : 0
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.existing[0].id]
#   }
#   filter {
#     name   = "tag:Tier"
#     values = ["private"]
#   }
# }
# RDS Subnet Group (Using Private Subnets)
resource "aws_db_subnet_group" "private_db" {
  count = var.deploy_private_rds ? 1 : 0

  name        = "${terraform.workspace}-${local.project_name.name}-private-db-subnet-group"
  subnet_ids  = terraform.workspace == "dev" ? aws_subnet.lumifi_subnets[*].id : data.aws_subnets.private.ids
  description = "Private DB subnet group for ${terraform.workspace} environment"
  tags = merge(local.tags, {
    Name        = "${terraform.workspace}-${local.project_name.name}-pvt-db-subnet-group"
    Environment = terraform.workspace
  })
}

# Private PostgreSQL RDS Instance with KMS Encryption
resource "aws_db_instance" "postgres_private" {
  count = var.deploy_private_rds ? 1 : 0

  identifier        = "${terraform.workspace}-db-private"
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
  final_snapshot_identifier = terraform.workspace == "prod" ? "${terraform.workspace}-db-final-snapshot" : null
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
