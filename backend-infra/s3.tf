# S3 Bucket - Backend Data
resource "aws_s3_bucket" "backend" {
  bucket = "${local.project_name.name}-${terraform.workspace}-backend"
  tags   = local.tags
}
resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Disabled"
  }
}

# S3 Bucket - Logs Storage
resource "aws_s3_bucket" "logs" {
  bucket = "${local.project_name.name}-${terraform.workspace}-logs"
  tags   = local.tags
}
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
# # Public Access Block for Logs Bucket (Restrict in Prod)  
# resource "aws_s3_bucket_public_access_block" "logs" {
#   bucket                  = aws_s3_bucket.logs.id
#   block_public_acls       = terraform.workspace == "prod" ? true : false
#   block_public_policy     = terraform.workspace == "prod" ? true : false
#   ignore_public_acls      = terraform.workspace == "prod" ? true : false
#   restrict_public_buckets = terraform.workspace == "prod" ? true : false

# }
# Always block public access (for all environments)
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
## Encryption Configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "backend_sse" {
  bucket = aws_s3_bucket.backend.id


  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3 (AES-256) or use aws:kms for SSE-KMS
    }
  }
}
