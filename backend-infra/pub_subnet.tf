# VPC Configuration
resource "aws_vpc" "lumifi-vpc" {
  count = terraform.workspace == "dev" ? 1 : 0
  # Only create the VPC if it doesn't exist. You can import the existing VPC for dev.
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${local.project_name.name}-vpc"
  }
}

# Public Subnets Configuration (One per Availability Zone)
resource "aws_subnet" "lumifi_subnets" {
  count = terraform.workspace == "dev" ? length(local.avail_zones) : 0

  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id

  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index + 1)
  availability_zone       = local.avail_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name.name}-subnet-${count.index + 1}"
    Tier = "public"
  }
}

# Internet Gateway for Public Access
resource "aws_internet_gateway" "lumifi-igw" {
  count  = terraform.workspace == "dev" ? 1 : 0
  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id

  tags = {
    Name = "${local.project_name.name}-IGW"
  }
}

# Public Route Table Configuration
resource "aws_route_table" "lumifi-pub-rt" {
  count  = terraform.workspace == "dev" ? 1 : 0
  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id

  depends_on = [aws_internet_gateway.lumifi-igw[0]]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = terraform.workspace == "dev" ? aws_internet_gateway.lumifi-igw[0].id : data.aws_internet_gateway.existing[0].id
  }

  tags = {
    Name = "${local.project_name.name}-MainRT"
  }
}

# Associate Route Table with All Public Subnets
resource "aws_route_table_association" "subnet_associations" {
  # count = length(aws_subnet.lumifi_subnets)
  count = terraform.workspace == "dev" ? length(local.avail_zones) : 0 # Only create in dev

  subnet_id      = aws_subnet.lumifi_subnets[count.index].id
  route_table_id = terraform.workspace == "dev" ? aws_route_table.lumifi-pub-rt[0].id : try(data.aws_route_tables.public[0].ids[0], null)
}

# ------------------------------
# Data Sources for Existing Prod VPC
# ------------------------------
data "aws_vpc" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${local.project_name.name}-vpc"]
  }
}
data "aws_subnets" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
}
data "aws_subnets" "public" {
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

# data "aws_internet_gateway" "existing" {
#   count = terraform.workspace == "prod" ? 1 : 0
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.existing[0].id]
#   }
# }

data "aws_route_tables" "public" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  filter {
    name   = "tag:Name"   # Changed from "tag:Tier"
    values = ["*MainRT*"] # Looks for Name tags containing "MainRT"
  }
}
# ------------------------------
# Data Source for Existing Internet Gateway (Prod)
# ------------------------------
data "aws_internet_gateway" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0

  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }

  # Optional: if you named it during dev creation
  # filter {
  #   name   = "tag:Name"
  #   values = ["dev-lumifitest-IGW"]
  # }
}
