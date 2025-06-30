# Terraform Block with Required Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# AWS Provider Configuration
provider "aws" {
  region  = local.aws_region
  profile = "lumifitest"
}

