resource "aws_vpc" "cloud" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.cloud.id
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.cloud.id

  count             = length(var.public_subnet_cidrs)
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.cloud.id

  count             = length(var.private_subnet_cidrs)
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
}