data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "swarm_manager" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.private[0].id
  vpc_security_group_ids      = [aws_security_group.swarm.id]
  iam_instance_profile        = aws_iam_instance_profile.nexora_profile.name
  associate_public_ip_address = false

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name        = "nexora-uat-manager"
    Environment = "uat"
    Project     = "nexora"
    Role        = "manager"
  }
}

resource "aws_instance" "swarm_worker" {
  count = 2

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.private[count.index + 1].id
  vpc_security_group_ids      = [aws_security_group.swarm.id]
  iam_instance_profile        = aws_iam_instance_profile.nexora_profile.name
  associate_public_ip_address = false

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name        = "nexora-uat-worker-${count.index + 1}"
    Environment = "uat"
    Project     = "nexora"
    Role        = "worker"
  }
}

resource "aws_ecr_repository" "backend" {

  name         = "nexora-api"
  force_delete = true
}

resource "aws_ecr_repository" "frontend" {
  name         = "nexora-frontend"
  force_delete = true
}
resource "aws_ecr_repository" "worker" {
  name         = "nexora-worker"
  force_delete = true
}
resource "aws_ecr_repository" "celery_publisher" {
  name         = "nexora-celery-publisher"
  force_delete = true
}
