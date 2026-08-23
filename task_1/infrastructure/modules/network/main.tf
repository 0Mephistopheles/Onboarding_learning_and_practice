locals {
  parsed_virtual_private_clouds = flatten([
    for cloud_name, cloud_info in var.virtual_private_clouds : [
      for subnet_name, subnet_info in cloud_info.vpc_subnets : {
        cloud_name  = cloud_name
        subnet_name = subnet_name
        subnet      = subnet_info
      }
    ]
  ])

  packed_subnet = {
    for parsed_subnet in local.parsed_virtual_private_clouds :
    "${parsed_subnet.cloud_name}.${parsed_subnet.subnet_name}" => parsed_subnet
  }

  enabled_nat_vpcs = {
    for cloud_name, cloud_info in var.virtual_private_clouds :
    cloud_name => cloud_info
    if cloud_info.routing_configuration.enable_nat
  }
}

resource "aws_vpc" "cloud" {
  for_each = var.virtual_private_clouds

  cidr_block           = each.value.vpc_cidr
  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support
}

resource "aws_internet_gateway" "gateway" {
  for_each = var.virtual_private_clouds

  vpc_id = aws_vpc.cloud[each.key].id
}

resource "aws_subnet" "subnet" {
  for_each = local.packed_subnet

  vpc_id            = aws_vpc.cloud[each.value.cloud_name].id
  cidr_block        = each.value.subnet.subnet_cidr
  availability_zone = each.value.subnet.availability_zone
}

resource "aws_route_table" "public" {
  for_each = var.virtual_private_clouds

  vpc_id = aws_vpc.cloud[each.key].id
}

resource "aws_route" "public_internet" {
  for_each = var.virtual_private_clouds

  route_table_id         = aws_route_table.public[each.key].id
  gateway_id             = aws_internet_gateway.gateway[each.key].id
  destination_cidr_block = each.value.routing_configuration.destination_cidr_block
}

resource "aws_route_table_association" "public" {
  for_each = {
    for subnet_name, subnet in local.packed_subnet :
    subnet_name => subnet
    if subnet.subnet.type == "public"
  }

  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.public[each.value.cloud_name].id
}

resource "aws_route_table" "private" {
  for_each = var.virtual_private_clouds

  vpc_id = aws_vpc.cloud[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = {
    for subnet_name, subnet in local.packed_subnet :
    subnet_name => subnet
    if subnet.subnet.type == "private"
  }
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.private[each.value.cloud_name].id
}

resource "aws_eip" "nat" {
  for_each = local.enabled_nat_vpcs

  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  for_each = {
    for cloud_name, cloud_info in local.enabled_nat_vpcs :
    cloud_name => ([
      for subnet_name, subnet_info in local.packed_subnet :
      subnet_name
      if(subnet_info.subnet.type == "public" &&
        subnet_info.cloud_name == cloud_name &&
        subnet_info.subnet_name ==
      cloud_info.routing_configuration.nat_location_name)
    ][0])
  }

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.subnet[each.value].id
}

resource "aws_route" "private_nat" {
  for_each = local.enabled_nat_vpcs

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = each.value.routing_configuration.destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}