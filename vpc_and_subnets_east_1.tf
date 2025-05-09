# Define the VPC
resource "aws_vpc" "main_vpc_virginia" {
  cidr_block = "10.0.0.0/16"
  provider = aws.virginia
  tags = {
    Name = "main_vpc_virginia"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "main_igw_virginia" {
  vpc_id = aws_vpc.main_vpc_virginia.id
  tags = {
    Name = "main_igw_virginia"
  }
}

# Public Subnet (for WordPress) B
resource "aws_subnet" "public_subnet_virginia_b" {
  vpc_id                  = aws_vpc.main_vpc_virginia.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"  # Adjust based on your region
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_virginia_b"
  }
}



# Public Subnet (for WordPress) A
resource "aws_subnet" "public_subnet_virginia" {
  vpc_id                  = aws_vpc.main_vpc_virginia.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Adjust based on your region
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_virginia"
  }
}

# Private Subnet (for MariaDB)
resource "aws_subnet" "private_subnet_virginia" {
  vpc_id                  = aws_vpc.main_vpc_virginia.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"  # Adjust based on your region
  tags = {
    Name = "private_subnet_virginia"
  }
}

# # Elastic IP for NAT Gateway A
# resource "aws_eip" "nat_eip_virginia" {
#   domain = "vpc"
# }

# # Elastic IP for NAT Gateway B
# resource "aws_eip" "nat_eip_virginia_b" {
#   domain = "vpc"
# }


# # Create NAT Gateway in the public subnet A
# resource "aws_nat_gateway" "main_nat_gateway_virginia" {
#   allocation_id = aws_eip.nat_eip_virginia.id
#   subnet_id = aws_subnet.public_subnet_virginia.id
#   tags = {
#     Name = "main_nat_gateway_virginia"
#   }
# }

# # Create NAT Gateway in the public subnet B
# resource "aws_nat_gateway" "main_nat_gateway_virginia_b" {
#   allocation_id = aws_eip.nat_eip_virginia_b.id
#   subnet_id = aws_subnet.public_subnet_virginia_b.id
#   tags = {
#     Name = "main_nat_gateway_virginia_b"
#   }
# }

# Route Table for Public Subnet (via Internet Gateway)
resource "aws_route_table" "public_route_table_virginia" {
  vpc_id = aws_vpc.main_vpc_virginia.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw_virginia.id
  }

  tags = {
    Name = "public_route_table_virginia"
  }
}

# Route Table for Private Subnet (via NAT Gateway) A
resource "aws_route_table" "private_route_table_virginia" {
  vpc_id = aws_vpc.main_vpc_virginia.id
  tags = {
    Name = "private_route_table_virginia"
  }
}

# # Route Table for Private Subnet (via NAT Gateway) B
# resource "aws_route_table" "private_route_table_virginia_b" {
#   vpc_id = aws_vpc.main_vpc_virginia.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main_nat_gateway_virginia_b.id
#   }

#   tags = {
#     Name = "private_route_table_virginia_b"
#   }
# }


# Associate route table with public subnet A 
resource "aws_route_table_association" "public_subnet_association_virginia" {
  subnet_id      = aws_subnet.public_subnet_virginia.id
  route_table_id = aws_route_table.public_route_table_virginia.id
}

# Associate route table with public subnet B
resource "aws_route_table_association" "public_subnet_association_virginia_b" {
  subnet_id      = aws_subnet.public_subnet_virginia_b.id
  route_table_id = aws_route_table.public_route_table_virginia.id
}

# Associate route table with private subnet A
resource "aws_route_table_association" "private_subnet_association_virginia" {
  subnet_id      = aws_subnet.private_subnet_virginia.id
  route_table_id = aws_route_table.private_route_table_virginia.id
}

# # Associate route table with private subnet B
# resource "aws_route_table_association" "private_subnet_association_virginia_b" {
#   subnet_id      = aws_subnet.private_subnet_virginia.id
#   route_table_id = aws_route_table.private_route_table_virginia_b.id
# }



resource "aws_lb_target_group" "app_tg_virginia" {
  provider            = aws.virginia
  name                = "app-tg-virginia"
  port                = 80
  protocol            = "HTTP"
  vpc_id              = aws_vpc.main_vpc_virginia.id
  target_type         = "instance"
}

resource "aws_lb_listener" "app_listener_virginia" {
  provider            = aws.virginia
  load_balancer_arn  = aws_lb.app_lb_virginia.arn
  port                = 80
  protocol            = "HTTP"
  default_action {
    type               = "forward"
    target_group_arn   = aws_lb_target_group.app_tg_virginia.arn
  }
}