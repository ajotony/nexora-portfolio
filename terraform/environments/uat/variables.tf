variable "aws_region" {
  description = "AWS region for Nexora infrastructure."
  type        = string
}

variable "key_name" {
  description = "AWS EC2 SSH key pair name."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.small"
}

variable "domain_name" {
  description = "Root domain managed through Route 53."
  type        = string
}

variable "app_subdomain" {
  description = "Frontend application subdomain."
  type        = string
  default     = "nexora"
}

variable "api_subdomain" {
  description = "API application subdomain."
  type        = string
  default     = "api.nexora"
}