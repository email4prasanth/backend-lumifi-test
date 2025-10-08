# Security Group for RDS PostgreSQL Access
resource "aws_security_group" "rds" {
  count = var.deploy_public_rds ? 1 : 0

  name        = "${terraform.workspace}-rds-sg"
  description = "Restricted access to PostgreSQL"
  vpc_id      = aws_vpc.lumifi-vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

