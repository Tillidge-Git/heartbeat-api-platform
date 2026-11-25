resource "aws_vpc_endpoint" "heartbeat_s3_ep" {
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_id            = aws_vpc.heartbeat_vpc.id
  route_table_ids   = [aws_route_table.heartbeat_priv_rt.id]

  tags = {
    Name = "heartbeat_s3_ep"
  }
}

resource "aws_vpc_endpoint" "heartbeat_dynamodb_ep" {
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_id            = aws_vpc.heartbeat_vpc.id
  route_table_ids   = [aws_route_table.heartbeat_priv_rt.id]

  tags = {
    Name = "heartbeat_dynamodb_ep"
  }
}

resource "aws_vpc_endpoint" "heartbeat_ssm_ep" {
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_id              = aws_vpc.heartbeat_vpc.id
  security_group_ids  = [aws_security_group.heartbeat_endpoint_sg.id]
  subnet_ids          = [aws_subnet.heartbeat_priv_sub_A.id, aws_subnet.heartbeat_priv_sub_B.id]
  private_dns_enabled = true

  tags = {
    Name = "heartbeat_ssm_ep"
  }
}

resource "aws_vpc_endpoint" "heartbeat_ssmmessages_ep" {
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_id              = aws_vpc.heartbeat_vpc.id
  security_group_ids  = [aws_security_group.heartbeat_endpoint_sg.id]
  subnet_ids          = [aws_subnet.heartbeat_priv_sub_A.id, aws_subnet.heartbeat_priv_sub_B.id]
  private_dns_enabled = true

  tags = {
    Name = "heartbeat_ssmmessages_ep"
  }
}

resource "aws_vpc_endpoint" "heartbeat_logs_ep" {
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_id              = aws_vpc.heartbeat_vpc.id
  security_group_ids  = [aws_security_group.heartbeat_endpoint_sg.id]
  subnet_ids          = [aws_subnet.heartbeat_priv_sub_A.id, aws_subnet.heartbeat_priv_sub_B.id]
  private_dns_enabled = true

  tags = {
    Name = "heartbeat_logs_ep"
  }
}