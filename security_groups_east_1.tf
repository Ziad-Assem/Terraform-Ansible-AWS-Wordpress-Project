# Security Group for WordPress (Public Subnet)
resource "aws_security_group" "wordpress_sg_virginia" {
  name        = "wordpress_sg_virginia"
  description = "Allow HTTP/HTTPS and SSH to WordPress instances"
  vpc_id      = aws_vpc.main_vpc_virginia.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.ansible_controlServer_virginia.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Ansible control server (public)
resource "aws_security_group" "ansible_sg_virginia" {
  name        = "ansible_sg_virginia"
  description = "Allow SSH to all instances"
  vpc_id      = aws_vpc.main_vpc_virginia.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Security Group for MariaDB (Private Subnet)
resource "aws_security_group" "mariadb_sg_virginia" {
  name        = "mariadb_sg_virginia"
  description = "Allow MariaDB connections from WordPress"
  vpc_id      = aws_vpc.main_vpc_virginia.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks =  ["${aws_instance.ansible_controlServer_virginia.private_ip}/32"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.wordpress_virginia.private_ip}/32"]  # Allow traffic from public subnet
  }

    ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.wordpress_virginia_b.private_ip}/32"]  # Allow traffic from public subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg_virginia" {
  provider = aws.virginia
  name     = "alb_sg_virginia"
  vpc_id   = aws_vpc.main_vpc_virginia.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_sg_virginia"
  }
}