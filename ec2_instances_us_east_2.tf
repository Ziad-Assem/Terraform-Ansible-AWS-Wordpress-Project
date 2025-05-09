# WordPress EC2 instance (Apache, PHP)
resource "aws_instance" "wordpress_ohio" {
    provider = aws.ohio
    ami           = var.ami_ubuntu_east_2  # Replace with appropriate AMI for WordPress
    instance_type = var.instance_type
    key_name = var.key-ec2
    subnet_id     = aws_subnet.public_subnet_ohio.id
    vpc_security_group_ids = [aws_security_group.wordpress_sg_ohio.id]
    associate_public_ip_address = true

    tags = {
        Name = "wordpress_instance AZ 1"
    }
}

# WordPress EC2 instance (Apache, PHP) in another public subnet
resource "aws_instance" "wordpress_ohio_b" {
    provider = aws.ohio
    ami           = var.ami_ubuntu_east_2  # Replace with appropriate AMI for WordPress
    instance_type = var.instance_type
    key_name = var.key-ec2
    subnet_id     = aws_subnet.public_subnet_ohio_b.id
    vpc_security_group_ids = [aws_security_group.wordpress_sg_ohio.id]
    associate_public_ip_address = true

    tags = {
        Name = "wordpress_instance AZ 2"
    }
}


# MariaDB EC2 instance (Private Subnet)
resource "aws_instance" "mariadb_ohio" {
    provider = aws.ohio
    ami           = var.ami_ubuntu_east_2 # Replace with appropriate AMI for MariaDB
    instance_type = var.instance_type
    key_name = var.key-ec2
    subnet_id     = aws_subnet.private_subnet_ohio.id
    vpc_security_group_ids = [aws_security_group.mariadb_sg_ohio.id]

    tags = {
        Name = "mariadb_instance"
    }
}