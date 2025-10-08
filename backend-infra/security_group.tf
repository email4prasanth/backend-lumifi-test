
# Security Group for Lumifi Resources Access
resource "aws_security_group" "lumifi_sg" {
  name        = "${terraform.workspace}-${local.project_name.name}-sg"
  description = "Security group for lumifi instances"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


  dynamic "ingress" {
    for_each = [for rule in local.sg : rule if rule.type == "ingress"]
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = [for rule in local.sg : rule if rule.type == "egress"]
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${local.project_name.name}-sg-${terraform.workspace}"
  }
}
# Security Group for Lambda Function
resource "aws_security_group" "lambda_sg" {
  name        = "${terraform.workspace}-lambda-sg"
  description = "Lambda access to RDS and internet"
  vpc_id      = terraform.workspace == "prod" ? data.aws_vpc.existing[0].id : aws_vpc.lumifi-vpc[0].id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.project_name.name}-lambda-sg-${terraform.workspace}"
  })
}