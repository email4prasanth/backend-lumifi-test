# VPC Configuration
resource "aws_vpc" "lumifi-vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${terraform.workspace}-${local.project_name.name}-vpc"
  }
}

# Public Subnets Configuration (One per Availability Zone)
resource "aws_subnet" "lumifi_subnets" {
  count = length(local.avail_zones)

  vpc_id                  = aws_vpc.lumifi-vpc.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index + 1)
  availability_zone       = local.avail_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${terraform.workspace}-${local.project_name.name}-subnet-${count.index + 1}"
    Tier = "public"
  }
}

# Internet Gateway for Public Access
resource "aws_internet_gateway" "lumifi-igw" {
  vpc_id = aws_vpc.lumifi-vpc.id
  tags = {
    Name = "${terraform.workspace}-${local.project_name.name}-IGW"
  }
}

# Public Route Table Configuration
resource "aws_route_table" "lumifi-pub-rt" {
  vpc_id     = aws_vpc.lumifi-vpc.id
  depends_on = [aws_internet_gateway.lumifi-igw]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lumifi-igw.id
  }

  tags = {
    Name = "${terraform.workspace}-${local.project_name.name}-MainRT"
  }
}

# Associate Route Table with All Public Subnets
resource "aws_route_table_association" "subnet_associations" {
  count = length(aws_subnet.lumifi_subnets)

  subnet_id      = aws_subnet.lumifi_subnets[count.index].id
  route_table_id = aws_route_table.lumifi-pub-rt.id
}
