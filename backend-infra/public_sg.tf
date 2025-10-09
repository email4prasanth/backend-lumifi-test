# # Security Group for RDS PostgreSQL Access
# resource "aws_security_group" "rds" {
#   count = var.deploy_public_rds ? 1 : 0

#   name        = "${terraform.workspace}-rds-sg"
#   description = "Restricted access to PostgreSQL"
#   vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


#   ingress {
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     # security_groups = [aws_security_group.lambda_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = local.tags
# }

# Security Group for Public RDS PostgreSQL Access (Dev)
resource "aws_security_group" "rds_public" {
  count = var.deploy_public_rds ? 1 : 0

  name        = "${local.project_name.name}-${terraform.workspace}-rds-public"
  description = "Public RDS PostgreSQL access for development"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id

  # Allow PostgreSQL from anywhere (for pgAdmin4 access in dev)
  ingress {
    description = "Allow PostgreSQL access from anywhere for development"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow PostgreSQL from Lambda security group
  ingress {
    description     = "Allow PostgreSQL access from Lambda functions"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.project_name.name}-${terraform.workspace}-rds-public"
  })
}