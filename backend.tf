# Terraform Remote Backend Configuration - S3 for backend code
terraform {
  backend "s3" {
    bucket  = "lumifitfstore"
    key     = "backend/terraform.tfstate"
    region  = local.aws_region
    # profile = "lumifitest"
  }
}