output "vpc_id" {
  description = "Nexora VPC ID"
  value       = aws_vpc.nexora.id
}

output "alb_dns_name" {
  description = "Nexora Application Load Balancer DNS name"
  value       = aws_lb.nexora.dns_name
}

output "alb_zone_id" {
  description = "Nexora Application Load Balancer hosted zone ID"
  value       = aws_lb.nexora.zone_id
}

output "manager_instance_id" {
  description = "Swarm manager EC2 instance ID"
  value       = aws_instance.swarm_manager.id
}

output "manager_private_ip" {
  description = "Swarm manager private IP"
  value       = aws_instance.swarm_manager.private_ip
}

output "worker_instance_ids" {
  description = "Swarm worker EC2 instance IDs"
  value       = aws_instance.swarm_worker[*].id
}

output "worker_private_ips" {
  description = "Swarm worker private IPs"
  value       = aws_instance.swarm_worker[*].private_ip
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "swarm_security_group_id" {
  description = "Swarm node security group ID"
  value       = aws_security_group.swarm.id
}

output "backend_ecr_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "worker_1_instance_id" {
  description = "Swarm worker 1 instance ID"
  value       = aws_instance.swarm_worker[0].id
}

output "worker_2_instance_id" {
  description = "Swarm worker 2 instance ID"
  value       = aws_instance.swarm_worker[1].id
}
output "worker_ecr_repository_url" {
  description = "Worker ECR repository URL"
  value       = aws_ecr_repository.worker.repository_url
}
