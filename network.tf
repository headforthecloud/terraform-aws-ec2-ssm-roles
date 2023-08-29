resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ec2_ssm_test_vpc"
  }
}

# Setup public subnet, internet gateway and route table

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.vpc_public_subnet_cidr

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "InternetGateway"
  }
}

resource "aws_route_table" "igw_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "igw_route_table"
  }
}

resource "aws_route_table_association" "igw_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.igw_route_table.id
}

# Setup security groups for EC2s managed via SSM
# resource "aws_security_group" "ec2_security_group" {
#   name        = "ec2_ssm_test_sg"
#   description = "Security Group for building ec2s to test SSM roles"

#   vpc_id = aws_vpc.vpc.id

# }

# resource "aws_security_group_rule" "ec2_outgoing" {
#   security_group_id = aws_security_group.ec2_security_group.id
#   type              = "egress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]

# }


resource "aws_eip" "nat_gateway_eip" {
  count = var.enable_nat_gateway ? 1 : 0

  vpc   = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.vpc_private_subnet_cidr

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat_gateway_eip[0].id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    "Name" = "NatGateway"
  }
}

resource "aws_default_route_table" "nat_gateway_route_table" {
  count = var.enable_nat_gateway ? 1 : 0
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  # vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[0].id
  }

  tags = {
    "Name" = "nat_route_table"
  }
}





# # resource "aws_security_group_rule" "endpoint_incoming" {
# #     security_group_id        = aws_security_group.endpoint_security_group.id
# #     type                     = "ingress"
# #     from_port                = 443
# #     to_port                  = 443
# #     protocol                 = "tcp"
# #     source_security_group_id = aws_security_group.ec2_security_group.id
# # }
