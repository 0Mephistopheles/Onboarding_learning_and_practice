output "vpc_ids" {
  value = {
    for name, vpc in aws_vpc.cloud : name => vpc.id
  }
}

output "internet_gateway_ids" {
  value = {
    for name, gateway in aws_internet_gateway.gateway : name => gateway.id
  }
}

output "public_subnet_ids" {
  value = {
    for name, subnet in aws_subnet.subnet :
    name => subnet.id
    if local.packed_subnet[name].subnet.type == "public"
  }
}

output "private_subnet_ids" {
  value = {
    for name, subnet in aws_subnet.subnet :
    name => subnet.id
    if local.packed_subnet[name].subnet.type == "private"
  }
}

output "public_route_table_ids" {
  value = {
    for name, route_table in aws_route_table.public :
    name => route_table.id
  }
}

output "private_route_table_ids" {
  value = {
    for name, route_table in aws_route_table.private :
    name => route_table.id
  }
}

output "nat_gateway_ids" {
  value = {
    for name, nat_gateway in aws_nat_gateway.nat :
    name => nat_gateway.id
  }
}

output "nat_eip_ids" {
  value = {
    for name, eip in aws_eip.nat :
    name => eip.id
  }
}