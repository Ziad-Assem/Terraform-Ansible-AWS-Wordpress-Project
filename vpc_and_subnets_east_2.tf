# Define the VPC
resource "aws_vpc" "main_vpc_ohio" {
  provider   = aws.ohio
  cidr_block = "11.0.0.0/16"
  tags = {
    Name = "main_vpc_ohio"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "main_igw_ohio" {
  provider = aws.ohio
  vpc_id   = aws_vpc.main_vpc_ohio.id
  tags = {
    Name = "main_igw_ohio"
  }
}


# Subnet for wordpress az us-east2b
resource "aws_subnet" "public_subnet_ohio_b" {
  provider                = aws.ohio
  vpc_id                  = aws_vpc.main_vpc_ohio.id
  cidr_block              = "11.0.3.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_ohio_b"
  }
}


# Public Subnet (for WordPress)
resource "aws_subnet" "public_subnet_ohio" {
  provider                = aws.ohio
  vpc_id                  = aws_vpc.main_vpc_ohio.id
  cidr_block              = "11.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_ohio"
  }
}

# Private Subnet (for MariaDB)
resource "aws_subnet" "private_subnet_ohio" {
  provider          = aws.ohio
  vpc_id            = aws_vpc.main_vpc_ohio.id
  cidr_block        = "11.0.2.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "private_subnet_ohio"
  }
}

# # Elastic IP for NAT Gateway
# resource "aws_eip" "nat_eip_ohio" {
#   provider = aws.ohio
#   domain   = "vpc"
# }

# resource "aws_eip" "nat_eip_ohio_b" {
#   provider = aws.ohio
#   domain   = "vpc"
# }

# # Create NAT Gateway in the public subnet
# resource "aws_nat_gateway" "main_nat_gateway_ohio" {
#   provider      = aws.ohio
#   allocation_id = aws_eip.nat_eip_ohio.id
#   subnet_id     = aws_subnet.public_subnet_ohio.id
#   tags = {
#     Name = "main_nat_gateway_ohio"
#   }
# }



# Route Table for Public Subnet (via Internet Gateway)
resource "aws_route_table" "public_route_table_ohio" {
  provider = aws.ohio
  vpc_id   = aws_vpc.main_vpc_ohio.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw_ohio.id
  }
  tags = {
    Name = "public_route_table_ohio"
  }
}

# # Create NAT Gateway in the public subnet
# resource "aws_nat_gateway" "main_nat_gateway_ohio_b" {
#   provider      = aws.ohio
#   allocation_id = aws_eip.nat_eip_ohio_b.id
#   subnet_id     = aws_subnet.public_subnet_ohio_b.id
#   tags = {
#     Name = "main_nat_gateway_ohio_b"
#     }
# }

# Route Table for Private Subnet (via NAT Gateway)
resource "aws_route_table" "private_route_table_ohio" {
  provider = aws.ohio
  vpc_id   = aws_vpc.main_vpc_ohio.id
  tags = {
    Name = "private_route_table_ohio"
  }
}

# # Route Table for Private Subnet (via NAT Gateway)
# resource "aws_route_table" "private_route_table_ohio_b" {
#   provider = aws.ohio
#   vpc_id   = aws_vpc.main_vpc_ohio.id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main_nat_gateway_ohio_b.id
#   }
#   tags = {
#     Name = "private_route_table_ohio_b"
#   }
# }

# Associate route table with public subnet
resource "aws_route_table_association" "public_subnet_association_ohio" {
  provider       = aws.ohio
  subnet_id      = aws_subnet.public_subnet_ohio.id
  route_table_id = aws_route_table.public_route_table_ohio.id
}

# Associate route table with public subnet b
resource "aws_route_table_association" "public_subnet_association_ohio_b" {
  provider       = aws.ohio
  subnet_id      = aws_subnet.public_subnet_ohio_b.id
  route_table_id = aws_route_table.public_route_table_ohio.id
}

# Associate route table with private subnet
resource "aws_route_table_association" "private_subnet_association_ohio" {
  provider       = aws.ohio
  subnet_id      = aws_subnet.private_subnet_ohio.id
  route_table_id = aws_route_table.private_route_table_ohio.id
}

# # Associate route table with private subnet b
# resource "aws_route_table_association" "private_subnet_association_ohio_b" {
#   provider       = aws.ohio
#   subnet_id      = aws_subnet.private_subnet_ohio.id
#   route_table_id = aws_route_table.private_route_table_ohio_b.id
# }


resource "aws_lb_target_group" "app_tg_ohio" {
  provider            = aws.ohio
  name                = "app-tg-ohio"
  port                = 80
  protocol            = "HTTP"
  vpc_id              = aws_vpc.main_vpc_ohio.id
  target_type         = "instance"
}

resource "aws_lb_listener" "app_listener_ohio" {
  provider            = aws.ohio
  load_balancer_arn  = aws_lb.app_lb_ohio.arn
  port                = 80
  protocol            = "HTTP"
  default_action {
    type               = "forward"
    target_group_arn   = aws_lb_target_group.app_tg_ohio.arn
  }
}
