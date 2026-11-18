resource "aws_vpc" "heartbeat_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "heartbeat_vpc"
  }
  #checkov:skip=CKV2_AWS_11:VPC flow logs to be added in there own PR.
}

resource "aws_default_security_group" "heartbeat_sg" {
  vpc_id = aws_vpc.heartbeat_vpc.id
}


resource "aws_internet_gateway" "heartbeat_igw" {
  vpc_id = aws_vpc.heartbeat_vpc.id
  tags = {
    Name = "heartbeat_igw"
  }
}

resource "aws_route_table" "heartbeat_pub_rt" {
  vpc_id = aws_vpc.heartbeat_vpc.id
  tags = {
    Name = "heartbeat_pub_rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.heartbeat_igw.id
  }
}

resource "aws_route_table" "heartbeat_priv_rt" {
  vpc_id = aws_vpc.heartbeat_vpc.id
  #endpoints added when made
  tags = {
    Name = "heartbeat_priv_rt"
  }
}



resource "aws_subnet" "heartbeat_pub_sub_A" {
  vpc_id                  = aws_vpc.heartbeat_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "heartbeat_pub_sub_A"
  }
}
resource "aws_route_table_association" "heartbeat_pub_rt_assoc_A" {
  subnet_id      = aws_subnet.heartbeat_pub_sub_A.id
  route_table_id = aws_route_table.heartbeat_pub_rt.id
}

resource "aws_subnet" "heartbeat_pub_sub_B" {
  vpc_id                  = aws_vpc.heartbeat_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = false
  tags = {
    Name = "heartbeat_pub_sub_B"
  }
}
resource "aws_route_table_association" "heartbeat_pub_rt_assoc_B" {
  subnet_id      = aws_subnet.heartbeat_pub_sub_B.id
  route_table_id = aws_route_table.heartbeat_pub_rt.id
}




resource "aws_subnet" "heartbeat_priv_sub_A" {
  vpc_id            = aws_vpc.heartbeat_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "heartbeat_priv_sub_A"
  }
}
resource "aws_route_table_association" "heartbeat_priv_rt_assoc_A" {
  subnet_id      = aws_subnet.heartbeat_priv_sub_A.id
  route_table_id = aws_route_table.heartbeat_priv_rt.id
}

resource "aws_subnet" "heartbeat_priv_sub_B" {
  vpc_id            = aws_vpc.heartbeat_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "heartbeat_priv_sub_B"
  }
}
resource "aws_route_table_association" "heartbeat_priv_rt_assoc_B" {
  subnet_id      = aws_subnet.heartbeat_priv_sub_B.id
  route_table_id = aws_route_table.heartbeat_priv_rt.id
}