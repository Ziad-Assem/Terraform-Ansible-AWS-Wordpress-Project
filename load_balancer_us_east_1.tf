resource "aws_lb" "app_lb_virginia" {
  provider           = aws.virginia
  name               = "app-lb-virginia"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg_virginia.id]
  subnets            = [aws_subnet.public_subnet_virginia.id, aws_subnet.public_subnet_virginia_b.id]
  enable_deletion_protection = false
  tags = {
    Name = "app-lb-virginia"
  }
}