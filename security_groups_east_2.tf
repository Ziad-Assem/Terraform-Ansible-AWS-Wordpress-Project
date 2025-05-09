# Security Group for WordPress (Public Subnet)
resource "aws_security_group" "wordpress_sg_ohio" {
  provider = aws.ohio
  name        = "wordpress_sg_ohio"
  description = "Allow HTTP/HTTPS and SSH to WordPress instances"
  vpc_id      = aws_vpc.main_vpc_ohio.id

  depends_on = [aws_vpc.main_vpc_ohio]

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

# Security Group for MariaDB (Private Subnet)
resource "aws_security_group" "mariadb_sg_ohio" {
  provider    = aws.ohio
  name        = "mariadb_sg_ohio"
  description = "Allow MariaDB connections from WordPress"
  vpc_id      = aws_vpc.main_vpc_ohio.id

  depends_on = [aws_vpc.main_vpc_ohio]

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
    cidr_blocks = ["${aws_instance.wordpress_ohio.private_ip}/32", "${aws_instance.wordpress_ohio_b.private_ip}/32"]  # Allow traffic from public subnet
  }

      ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.wordpress_ohio_b.private_ip}/32"]  # Allow traffic from public subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg_ohio" {
  provider = aws.ohio
  name     = "alb_sg_ohio"
  vpc_id   = aws_vpc.main_vpc_ohio.id

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
    Name = "alb_sg_ohio"
  }
}