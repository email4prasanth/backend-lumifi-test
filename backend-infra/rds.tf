# Random Password for RDS Admin
resource "random_password" "db_admin_password" {
  length           = 16
  special          = true
  override_special = "!$%^&*()-_=+?"
}
# RDS Subnet Group (Using Public Subnets)
resource "aws_db_subnet_group" "public_db" {
  name       = "${terraform.workspace}-lumifi-public-db-subnet-group"
  subnet_ids = aws_subnet.lumifi_subnets[*].id

  tags = merge(local.tags, {
    Name = "${terraform.workspace}-db-subnet-group"
  })
}

# Parameter Group to enforce SSL
resource "aws_db_parameter_group" "lumifi_pg" {
  name   = "${terraform.workspace}-lumifi-pg"
  family = "postgres15"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}

# PostgreSQL RDS Instance
resource "aws_db_instance" "postgres" {
  identifier        = "${terraform.workspace}-lumifi-db"
  allocated_storage = local.rds.allocated_storage
  storage_type      = "gp3"
  engine            = "postgres"
  engine_version    = "15"
  # Updated instance types per environment
  # instance_class = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.small"
  instance_class = terraform.workspace == "prod" ? "db.t4g.medium" : "db.t3.micro" # For testing
  # Multi-AZ configuration
  multi_az               = terraform.workspace == "prod" ? true : false
  db_name                = "${terraform.workspace}_lumifi"
  username               = "dbadmin"
  password               = random_password.db_admin_password.result
  # parameter_group_name   = "default.postgres15"
  parameter_group_name   = aws_db_parameter_group.lumifi_pg.name
  skip_final_snapshot    = terraform.workspace == "dev" ? true : false
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.public_db.name
  publicly_accessible    = true
  apply_immediately      = true
  tags                   = local.tags
  depends_on = [
    aws_internet_gateway.lumifi-igw,
    aws_route_table.lumifi-pub-rt,
    aws_security_group.lumifi_sg
  ]
}