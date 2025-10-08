# Reuse existing VPC instead of creating a new one
data "aws_vpc" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["lumifitest-vpc"]
  }
}
# reuse existing subnets
data "aws_subnets" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
}
# Public Route Table
data "aws_route_tables" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }

  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}
# Private Route Table
data "aws_route_tables" "existing_private" {
  count = terraform.workspace == "prod" ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }

  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}
