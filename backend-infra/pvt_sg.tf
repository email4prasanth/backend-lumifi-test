# Private RDS SG — allow only Lambda & Migration EC2.
# Lambda SG — allow outbound to RDS.
resource "aws_security_group" "lambda_sg_pvt" {
  count = var.deploy_private_rds ? 1 : 0

  name        = "${terraform.workspace}-lambda-pvt-sg"
  description = "Private Lambda access to private RDS"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.project_name.name}-lambda-pvt-sg-${terraform.workspace}"
  })
}

# RDS Private SG
resource "aws_security_group" "rds_private" {
  count = var.deploy_private_rds ? 1 : 0

  name   = "${terraform.workspace}-${local.project_name.name}-rds-pvt-sg"
  vpc_id = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg_pvt[0].id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

