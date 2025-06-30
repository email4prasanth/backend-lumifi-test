# Terraform Remote Backend Configuration - S3 for backend code
terraform {
  backend "s3" {
    bucket  = "lumifitfstore"
    key     = "backend/terraform.tfstate"
    region  = "us-east-1"
    profile = "lumifitest"
  }
}