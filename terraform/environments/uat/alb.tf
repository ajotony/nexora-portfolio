resource "aws_lb" "nexora" {
  name               = "nexora-uat-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = aws_subnet.public[*].id

  security_groups = [
    aws_security_group.alb.id
  ]

  tags = {
    Name        = "nexora-uat-alb"
    Environment = "uat"
    Project     = "nexora"
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "nexora-uat-frontend-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.nexora.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "3000"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name        = "nexora-uat-frontend-tg"
    Environment = "uat"
    Project     = "nexora"
  }
}

resource "aws_lb_target_group" "api" {
  name     = "nexora-uat-api-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.nexora.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    port                = "8080"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name        = "nexora-uat-api-tg"
    Environment = "uat"
    Project     = "nexora"
  }
}

resource "aws_lb_target_group_attachment" "frontend_manager" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.swarm_manager.id
  port             = 3000
}

resource "aws_lb_target_group_attachment" "frontend_workers" {
  count = 2

  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.swarm_worker[count.index].id
  port             = 3000
}

resource "aws_lb_target_group_attachment" "api_manager" {
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.swarm_manager.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "api_workers" {
  count = 2

  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.swarm_worker[count.index].id
  port             = 8080
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nexora.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  condition {
    host_header {
      values = ["nexora.anthonyajo.name.ng"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 200

  condition {
    host_header {
      values = ["api.nexora.anthonyajo.name.ng"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.nexora.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.nexora.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Nexora ALB"
      status_code  = "200"
    }
  }

  depends_on = [
    aws_acm_certificate_validation.nexora
  ]
}