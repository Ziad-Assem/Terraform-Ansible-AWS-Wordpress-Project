resource "aws_lb" "app_lb_ohio" {
  provider           = aws.ohio
  name               = "app-lb-ohio"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg_ohio.id]
  subnets            = [aws_subnet.public_subnet_ohio.id, aws_subnet.public_subnet_ohio_b.id]
  enable_deletion_protection = false
  tags = {
    Name = "app-lb-ohio"
  }
}