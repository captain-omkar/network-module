resource "aws_vpc" "AMI_vpc" {
    cidr_block       = var.vpc_cidr
    tags = {
    Name = "AMI-Network-vpc"
     }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.AMI_vpc.id
  tags = {
    Name = "AMI-Network-us-east-1-IGW"
  }
}

resource "aws_subnet" "private1" {
  for_each = var.private_subnets_1
  availability_zone = "ap-south-1a"
  vpc_id   = aws_vpc.AMI_vpc.id
  cidr_block = each.value["cidr"]
  
  tags = {
    Name = each.value["name"]
  }
}

resource "aws_subnet" "private2" {
  for_each = var.private_subnets_2
  availability_zone = "ap-south-1a"
  vpc_id   = aws_vpc.AMI_vpc.id
  cidr_block = each.value["cidr"]
  
  tags = {
    Name = each.value["name"]
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets
  availability_zone = "ap-south-1a"
  vpc_id   = aws_vpc.AMI_vpc.id
  cidr_block = each.value["cidr"]
  
  tags = {
    Name = each.value["name"]
  }
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.AMI_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "AMI-Network-Private-NACL"
  }
}

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.AMI_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "AMI-Network-Public-NACL"
  }
}

resource "aws_network_acl_association" "private_asc_1" {
  for_each = aws_subnet.private1
  network_acl_id = aws_network_acl.private.id
  subnet_id      = each.value.id
}

resource "aws_network_acl_association" "private_asc_2" {
  for_each = aws_subnet.private2
  network_acl_id = aws_network_acl.private.id
  subnet_id      = each.value.id
}

resource "aws_network_acl_association" "public_asc" {
  for_each = aws_subnet.public
  network_acl_id = aws_network_acl.private.id
  subnet_id      = each.value.id
}


