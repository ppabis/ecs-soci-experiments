#############################################################################
#                              VPC                                          #
#############################################################################
resource "aws_vpc" "main" {
  tags                 = { Name = "ecs-soci-vpc" }
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  tags   = { Name = "ecs-soci-igw" }
  vpc_id = aws_vpc.main.id
}

###############################################################################
#                          Public subnets                                     #
###############################################################################
resource "aws_subnet" "public_1" {
  tags                    = { Name = "ecs-soci-public-${var.aws_region}a" }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_2" {
  tags                    = { Name = "ecs-soci-public-${var.aws_region}b" }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  tags   = { Name = "ecs-soci-public-rt" }
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

################################################################################
#                          Private subnets                                     #
################################################################################
resource "aws_subnet" "private_1" {
  tags              = { Name = "ecs-soci-private-${var.aws_region}a" }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone = "${var.aws_region}a"
}

resource "aws_subnet" "private_2" {
  tags              = { Name = "ecs-soci-private-${var.aws_region}b" }
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 4)
  availability_zone = "${var.aws_region}b"
}

resource "aws_route_table" "private" {
  tags   = { Name = "ecs-soci-private-rt" }
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}