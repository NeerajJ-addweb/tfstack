resource "aws_vpc" "main" {
  cidr_block       = var.VpcCIDR
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.EnvironmentName
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.EnvironmentName
  }
}
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[0]
  map_public_ip_on_launch = true
  tags = {
    Name = var.EnvironmentName
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[1]
  map_public_ip_on_launch = true
  tags = {
    Name = var.EnvironmentName
  }
}
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[0]
  map_public_ip_on_launch = false
  tags = {
    Name = var.EnvironmentName
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[1]
  map_public_ip_on_launch = false
  tags = {
    Name = var.EnvironmentName
  }
}
resource "aws_eip" "nat_gateway_1_eip" {
  vpc      = true
}
resource "aws_eip" "nat_gateway_2_eip" {
  vpc      = true
}
resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_gateway_1_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "var.EnvironmentName NatGateway 1"
  }
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat_gateway_2_eip.id
  subnet_id     = aws_subnet.public_subnet_2.id
  tags = {
    Name = "var.EnvironmentName NatGateway 2"
  }
}