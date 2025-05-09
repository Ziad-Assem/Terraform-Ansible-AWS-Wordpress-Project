# WordPress EC2 instance (Apache, PHP)
resource "aws_instance" "wordpress_virginia" {
    provider = aws.virginia
    ami           = var.ami_ubuntu_east_1  # Replace with appropriate AMI for WordPress
    instance_type = var.instance_type
    key_name = var.key-ec2
    subnet_id     = aws_subnet.public_subnet_virginia.id
    vpc_security_group_ids = [aws_security_group.wordpress_sg_virginia.id]
    associate_public_ip_address = true

    tags = {
        Name = "wordpress_instance AZ 1"
    }
}

resource "aws_instance" "wordpress_virginia_b" {
    provider = aws.virginia
    ami           = var.ami_ubuntu_east_1  # Replace with appropriate AMI for WordPress
    instance_type = var.instance_type
    key_name = var.key-ec2
    subnet_id     = aws_subnet.public_subnet_virginia_b.id
    vpc_security_group_ids = [aws_security_group.wordpress_sg_virginia.id]
    associate_public_ip_address = true

    tags = {
        Name = "wordpress_instance AZ 2"
    }
}

# 
resource "aws_instance" "ansible_controlServer_virginia" {
    provider = aws.virginia
    ami           = var.ami_ubuntu_east_1  # Replace with appropriate AMI for WordPress
    instance_type = var.instance_type
    key_name = var.key-ec2
    subnet_id     = aws_subnet.public_subnet_virginia.id
    vpc_security_group_ids = [aws_security_group.ansible_sg_virginia.id]
    associate_public_ip_address = true

    user_data = file("/home/zozz/terraform-ansible-project/Ansible-Wordpress-Project/script.sh")

    tags = {
        Name = "ansible_controlServer"
    }    
}

# MariaDB EC2 instance (Private Subnet)
resource "aws_instance" "mariadb_virginia" {
    provider = aws.virginia
    ami           = var.ami_ubuntu_east_1 # Replace with appropriate AMI for MariaDB
    instance_type = var.instance_type
    key_name = var.key-ec2
    subnet_id     = aws_subnet.private_subnet_virginia.id
    vpc_security_group_ids = [aws_security_group.mariadb_sg_virginia.id]

    tags = {
        Name = "mariadb_instance"
    }
}