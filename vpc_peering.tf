resource "aws_vpc_peering_connection" "virginia_ohio" {
  provider = aws.virginia
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = aws_vpc.main_vpc_ohio.id
  vpc_id        = aws_vpc.main_vpc_virginia.id
  peer_region   = "us-east-2"

  tags = {
    Name = "virginia-ohio-peering"
  }
}

# Virginia VPC route to Ohio VPC
resource "aws_route" "virginia_to_ohio_public" {
  provider               = aws.virginia
  route_table_id         = aws_route_table.public_route_table_virginia.id
  destination_cidr_block = aws_vpc.main_vpc_ohio.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.virginia_ohio.id
}

resource "aws_route" "virginia_to_ohio_private" {
  provider               = aws.virginia
  route_table_id         = aws_route_table.private_route_table_virginia.id
  destination_cidr_block = aws_vpc.main_vpc_ohio.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.virginia_ohio.id
}


# Ohio VPC route to Virginia VPC public
resource "aws_route" "ohio_to_virginia_public" {
  provider               = aws.ohio
  route_table_id         = aws_route_table.public_route_table_ohio.id
  destination_cidr_block = aws_vpc.main_vpc_virginia.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.virginia_ohio.id
}

resource "aws_route" "ohio_to_virginia_private" {
  provider               = aws.ohio
  route_table_id         = aws_route_table.private_route_table_ohio.id
  destination_cidr_block = aws_vpc.main_vpc_virginia.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.virginia_ohio.id
}

# Accept the peering connection from the Ohio side
resource "aws_vpc_peering_connection_accepter" "accept_virginia_ohio" {
  provider                  = aws.ohio
  vpc_peering_connection_id = aws_vpc_peering_connection.virginia_ohio.id
  auto_accept               = true

  tags = {
    Name = "accept-virginia-ohio"
  }
}
