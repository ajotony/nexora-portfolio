resource "aws_security_group" "alb" {
  name        = "nexora-uat-alb-sg"
  description = "Security group for Nexora ALB"
  vpc_id      = aws_vpc.nexora.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
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
    Name        = "nexora-uat-alb-sg"
    Environment = "uat"
    Project     = "nexora"
  }
}

resource "aws_security_group" "swarm" {
  name        = "nexora-uat-swarm-sg"
  description = "Security group for Nexora Docker Swarm nodes"
  vpc_id      = aws_vpc.nexora.id

  ingress {
    description     = "Frontend traffic from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "API traffic from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Swarm management"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Swarm node communication TCP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Swarm node communication UDP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Swarm overlay networking"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Node Exporter metrics from Swarm nodes"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "cAdvisor metrics from Swarm nodes"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "nexora-uat-swarm-sg"
    Environment = "uat"
    Project     = "nexora"
  }
}