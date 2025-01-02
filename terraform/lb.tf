#Create Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
  enable_deletion_protection = false

  tags = {
    Name = "App Load Balancer"
  }
}

# Create Target Group for Load Balancer
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "App Target Group"
  }
}

# Attach EC2 Instances to Target Group
resource "aws_lb_target_group_attachment" "app_target_group_attachment" {
  count             = var.settings.app.count  # Loop through instances
  target_group_arn  = aws_lb_target_group.app_target_group.arn
  target_id         = aws_instance.app[count.index].id  # Dynamically reference instance IDs
  port              = 80
}

# Listener for Load Balancer
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
