#================================================
# ALB
#================================================
resource "aws_lb" "handson" {
  name               = "handson-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "handson-alb"
  }
}

#================================================
# Target Group
#================================================
resource "aws_lb_target_group" "handson" {
  name        = "handson-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.handson.id
  target_type = "ip"

  health_check {
    path = "/"
  }

  tags = {
    Name = "handson-tg"
  }
}

#================================================
# Listener
#================================================
resource "aws_lb_listener" "handson" {
  load_balancer_arn = aws_lb.handson.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.handson.arn
  }
}

#================================================
# Target Group Attachment (ECS Fargateでは不要、サービスで自動登録)
#================================================
