provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Nexora"
      ManagedBy   = "Terraform"
      Environment = "bootstrap"
    }
  }
}