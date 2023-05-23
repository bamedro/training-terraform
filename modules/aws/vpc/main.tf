resource "aws_vpc" "ldz" {
  cidr_block = var.cidr_block

#   tags = { Name = "${local.stack_name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.ldz.id
  cidr_block        = cidrsubnet(aws_vpc.ldz.cidr_block, 8, 1)

#   tags = { Name = "public-${local.stack_name}" }
}

resource "aws_internet_gateway" "ldz" {
  vpc_id = aws_vpc.ldz.id
}

resource "aws_route_table" "ldz" {
  vpc_id = aws_vpc.ldz.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ldz.id
  }
}

resource "aws_main_route_table_association" "ldz" {
  vpc_id         = aws_vpc.ldz.id
  route_table_id = aws_route_table.ldz.id
}
