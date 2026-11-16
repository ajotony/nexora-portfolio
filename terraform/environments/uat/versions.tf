terraform {
  required_version = "~> 1.16.0"

  backend "s3" {
    bucket       = "nexora-uat-tf-state-backend"
    key          = "uat/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}