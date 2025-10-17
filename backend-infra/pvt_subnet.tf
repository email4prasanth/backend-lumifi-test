# Private Subnets
resource "aws_subnet" "lumifi_private_subnets" {
  count = terraform.workspace == "dev" ? length(local.avail_zones) : 0

  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id

  cidr_block              = cidrsubnet(local.vpc_cidr, 8, count.index + 100)
  availability_zone       = local.avail_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.project_name.name}-private-subnet-${count.index + 1}"
    Tier = "private"
  }
}
# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = terraform.workspace == "dev" ? 1 : 0
  tags = {
    Name = "${local.project_name.name}-nat-eip"
  }
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
  count         = terraform.workspace == "dev" ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.lumifi_subnets[0].id # ✅ Should point to a public subnet
  tags = {
    Name = "${local.project_name.name}-nat-gateway"
  }
}
# Private Route Table
resource "aws_route_table" "private_rt" {
  count  = terraform.workspace == "dev" ? 1 : 0
  vpc_id = terraform.workspace == "dev" ? aws_vpc.lumifi-vpc[0].id : data.aws_vpc.existing[0].id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = terraform.workspace == "dev" ? aws_nat_gateway.nat[0].id : data.aws_nat_gateway.existing[0].id
  }

  tags = {
    Name = "${local.project_name.name}-private-rt"
  }
}
# Associate private subnets
resource "aws_route_table_association" "private_assoc" {
  # count          = length(aws_subnet.lumifi_private_subnets)
  # count          = length(local.avail_zones)
  count     = terraform.workspace == "dev" ? length(local.avail_zones) : 0 # Only create in dev
  subnet_id = aws_subnet.lumifi_private_subnets[count.index].id
  # route_table_id = terraform.workspace == "dev" ? aws_route_table.private_rt[0].id : try(data.aws_route_tables.private[0].ids[0], null)
  # route_table_id = terraform.workspace == "dev" ? aws_route_table.private_rt[0].id : data.aws_route_tables.private[0].ids[0]
  route_table_id = terraform.workspace == "dev" ? aws_route_table.private_rt[0].id : try(data.aws_route_tables.private[0].ids[0], null)
}
output "lumifi_private_subnets" {
  value = aws_subnet.lumifi_private_subnets[*].id
}
# ------------------------------
# Data Source for Private Route Tables in Prod
# ------------------------------
data "aws_route_tables" "private" {
  count = terraform.workspace == "prod" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  filter {
    name   = "tag:Name"    # Changed from "tag:Tier"
    values = ["*private*"] # Looks for Name tags containing "private"
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
# ------------------------------
# Data Source for Existing NAT Gateway (Prod)
# ------------------------------
data "aws_nat_gateway" "existing" {
  count = terraform.workspace == "prod" ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  # Optional: use tag if you named it
  # filter {
  #   name   = "tag:Name"
  #   values = ["${local.project_name.name}-nat-gateway-dev"]
  # }
}
