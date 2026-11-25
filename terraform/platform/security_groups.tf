resource "aws_security_group" "heartbeat_endpoint_sg" {
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.heartbeat_vpc.id
  tags = {
    Name = "heartbeat_endpoint_sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "heartbeat_endpoint_sg_ingress_rule" {
  security_group_id = aws_security_group.heartbeat_endpoint_sg.id
  description       = "Ingress rule for endpoint sg allowing HTTPS from VPC CIDR only."

  cidr_ipv4   = aws_vpc.heartbeat_vpc.cidr_block
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

  tags = {
    Name = "heartbeat_ep_sg_ingress_rule"
  }
}
