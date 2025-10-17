# # Private RDS SG — allow only Lambda & Migration EC2.
# # Lambda SG — allow outbound to RDS.
# resource "aws_security_group" "lambda_sg_pvt" {
#   count = var.deploy_private_rds ? 1 : 0

#   name        = "${terraform.workspace}-lambda-pvt-sg"
#   description = "Private Lambda access to private RDS"
#   vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(local.tags, {
#     Name = "${local.project_name.name}-lambda-pvt-sg-${terraform.workspace}"
#   })
# }

# # RDS Private SG
# resource "aws_security_group" "rds_private" {
#   count = var.deploy_private_rds ? 1 : 0

#   name   = "${terraform.workspace}-${local.project_name.name}-rds-pvt-sg"
#   vpc_id = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.lambda_sg_pvt[0].id]

#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = local.tags
# }
# ------------------------------
# Private Lambda Security Group for Production
# ------------------------------
resource "aws_security_group" "lambda_private" {
  count = var.deploy_private_rds ? 1 : 0

  name        = "${local.project_name.name}-${terraform.workspace}-lambda-private"
  description = "Private Lambda access to private RDS in production"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.project_name.name}-${terraform.workspace}-lambda-private"
  })
}

# Private RDS Security Group for Production
resource "aws_security_group" "rds_private" {
  count = var.deploy_private_rds ? 1 : 0

  name        = "${local.project_name.name}-${terraform.workspace}-rds-private"
  description = "Private RDS PostgreSQL access for production"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id

  # Inbound: allow PostgreSQL from Private Lambda SG only
  ingress {
    description     = "Allow PostgreSQL access from private Lambda functions"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_private[0].id]
    # security_groups = var.deploy_private_rds ? [aws_security_group.lambda_private[0].id] : []
  }
  # Inbound: allow PostgreSQL from Lambda SG only
  ingress {
    description     = "Allow PostgreSQL access from lambda rds functions"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg[0].id]
    # security_groups = var.deploy_private_rds ? [aws_security_group.lambda_private[0].id] : []
  }
  # Allow PostgreSQL from EC2 security group (for maintenance/access)
  ingress {
    description     = "Allow PostgreSQL access from EC2 instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    # security_groups = [aws_security_group.ec2[0].id]
    security_groups = var.deploy_private_rds ? [aws_security_group.ec2[0].id] : []
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
    Name = "${local.project_name.name}-${terraform.workspace}-rds-private"
  })
}

# EC2 Security Group for Production Access (New)
resource "aws_security_group" "ec2" {
  count = var.deploy_private_rds ? 1 : 0

  name        = "${local.project_name.name}-${terraform.workspace}-ec2"
  description = "EC2 instance for accessing private RDS in production"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id

  # Allow SSH access from anywhere (you can restrict this further)
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "${local.project_name.name}-${terraform.workspace}-ec2"
  })
}
