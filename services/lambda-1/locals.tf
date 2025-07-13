locals {
  aws_region = "us-east-1"
  # Tags, VPC CIDR, Availability Zones Configuration for Dev and Prod Environment
  tags = {
    owner       = "lumifi"
    environment = terraform.workspace
  }
} 