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