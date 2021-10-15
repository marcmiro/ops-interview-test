data "aws_availability_zones" "available" {}

# It's supposed from example that VPC (also Gateway and basic routetables) is created manually or with another stack
data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# Create subnets
resource "aws_subnet" "subnet_public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, "${10 + count.index}")
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

	tags = {
    App = var.app_name
    Type = "Public"
  }
}

resource "aws_subnet" "subnet_private" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, "${20 + count.index}")
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

	tags = {
    App = var.app_name
    Type = "Private"
  }
}

data "aws_subnet_ids" "subnets_public" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    App = var.app_name
    Type = "Public"
  }
}

data "aws_subnet_ids" "subnets_private" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    App = var.app_name
    Type = "Private"
  }
}

# NAT gateway for private
resource "aws_eip" "nat" {
  vpc      = true
  count         = length(data.aws_subnet_ids.subnets_private.ids)
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = element(aws_eip.nat.*.id, count.index)
  count         = length(data.aws_subnet_ids.subnets_private.ids)
  subnet_id     = data.aws_subnet_ids.subnets_private.ids[count.index]

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route_table" "nat_route_table" {
  count         = length(data.aws_subnet_ids.subnets_private.ids)
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  }

  tags = {
    Name = "NAT-route-table"
  }
}

resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
  count         = length(data.aws_subnet_ids.subnets_private.ids)
  subnet_id      = data.aws_subnet_ids.subnets_private.ids[count.index]
  route_table_id = element(aws_route_table.nat_route_table.*.id, count.index)
}
