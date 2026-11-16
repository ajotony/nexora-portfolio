data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "nexora" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "nexora-uat-vpc"
    Environment = "uat"
    Project     = "nexora"
  }
}

resource "aws_internet_gateway" "nexora" {
  vpc_id = aws_vpc.nexora.id

  tags = {
    Name        = "nexora-uat-igw"
    Environment = "uat"
    Project     = "nexora"
  }
}

resource "aws_subnet" "public" {
  count = 3

  vpc_id                  = aws_vpc.nexora.id
  cidr_block              = cidrsubnet(aws_vpc.nexora.cidr_block, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "nexora-uat-public-${count.index + 1}"
    Environment = "uat"
    Project     = "nexora"
    Tier        = "public"
  }
}

resource "aws_subnet" "private" {
  count = 3

  vpc_id            = aws_vpc.nexora.id
  cidr_block        = cidrsubnet(aws_vpc.nexora.cidr_block, 8, count.index + 11)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "nexora-uat-private-${count.index + 1}"
    Environment = "uat"
    Project     = "nexora"
    Tier        = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nexora.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nexora.id
  }

  tags = {
    Name        = "nexora-uat-public-rt"
    Environment = "uat"
    Project     = "nexora"
  }
}

resource "aws_route_table_association" "public" {
  count = 3

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "nexora-uat-nat-eip"
    Environment = "uat"
    Project     = "nexora"
  }

  depends_on = [aws_internet_gateway.nexora]
}

resource "aws_nat_gateway" "nexora" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name        = "nexora-uat-nat"
    Environment = "uat"
    Project     = "nexora"
  }

  depends_on = [aws_internet_gateway.nexora]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.nexora.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nexora.id
  }

  tags = {
    Name        = "nexora-uat-private-rt"
    Environment = "uat"
    Project     = "nexora"
  }
}

resource "aws_route_table_association" "private" {
  count = 3

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}